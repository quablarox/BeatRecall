import 'package:flutter/foundation.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/repositories/card_repository.dart';
import '../../../domain/value_objects/rating.dart';
import '../../../services/srs_service.dart';
import '../../../services/settings_service.dart';

/// View model for managing quiz/review session state.
/// 
/// **Features:**
/// - @DUEQUEUE-001 (Due Cards Retrieval)
/// - @DUEQUEUE-002 (Review Session Management)
/// - @DUEQUEUE-003 (Continuous Session Mode)
/// - @SETTINGS-001 (Daily New Cards Limit)
class QuizViewModel extends ChangeNotifier {
  final CardRepository _cardRepository;
  final SrsService _srsService;
  final SettingsService _settingsService;

  QuizViewModel({
    required CardRepository cardRepository,
    required SrsService srsService,
    required SettingsService settingsService,
  })  : _cardRepository = cardRepository,
        _srsService = srsService,
        _settingsService = settingsService;

  // Session state
  List<Flashcard> _dueCards = [];
  int _currentIndex = 0;
  int _displayedCardIndex = 0; // The card currently displayed (may lag behind _currentIndex during animation)
  bool _isLoading = false;
  String? _error;
  bool _showBack = false;

  // Session statistics
  final Map<int, int> _ratingCounts = {0: 0, 1: 0, 3: 0, 4: 0};
  DateTime? _sessionStartTime;
  int _totalReviewed = 0; // Total cards reviewed (including repeats)
  
  // New cards tracking
  int _newCardsStudiedInSession = 0;

  // Getters
  List<Flashcard> get dueCards => _dueCards;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showBack => _showBack;
  int get newCardsStudiedInSession => _newCardsStudiedInSession;
  
  Flashcard? get currentCard =>
      _dueCards.isNotEmpty && _displayedCardIndex < _dueCards.length
          ? _dueCards[_displayedCardIndex]
          : null;

  int get totalCards => _dueCards.length;
  int get remainingCards => _dueCards.length - _currentIndex;
  double get progress => _totalReviewed == 0 ? 0.0 : _currentIndex / (_totalReviewed + remainingCards);
  
  bool get isSessionComplete => _currentIndex >= _dueCards.length;

  Map<int, int> get ratingCounts => Map.unmodifiable(_ratingCounts);
  int get totalReviewed => _totalReviewed; // Use tracked total instead of sum

  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// Load due cards and optionally new cards, then start a new session
  /// 
  /// Priority order: Review cards (repetitions > 0) come first, then new cards
  Future<void> loadDueCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all due review cards (cards with repetitions > 0 and nextReviewDate <= now)
      final dueReviews = await _cardRepository.fetchDueCards();
      
      // Fetch new cards up to daily limit
      final remainingNewCards = _settingsService.getRemainingNewCardsToday();
      List<Flashcard> newCards = [];
      
      if (remainingNewCards > 0) {
        final allCards = await _cardRepository.fetchAllCards();
        // New cards are those with repetitions == 0
        newCards = allCards
            .where((card) => card.repetitions == 0)
            .take(remainingNewCards)
            .toList();
      }

      // Combine: reviews first (priority), then new cards
      _dueCards = [...dueReviews, ...newCards];
      _currentIndex = 0;
      _displayedCardIndex = 0;
      _showBack = false;
      _ratingCounts.clear();
      _ratingCounts.addAll({0: 0, 1: 0, 3: 0, 4: 0});
      _sessionStartTime = DateTime.now();
      _totalReviewed = 0;
      _newCardsStudiedInSession = 0;
    } catch (e) {
      _error = 'Failed to load due cards: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Flip the current card to show the back
  void flipCard() {
    _showBack = !_showBack;
    notifyListeners();
  }

  /// Rate the current card and move to the next one
  Future<void> rateCard(int rating, {Duration? advanceDelay}) async {
    if (currentCard == null) return;

    try {
      // Track if this was a new card
      final wasNewCard = currentCard!.repetitions == 0;
      
      // Convert int rating to Rating enum
      final ratingEnum = Rating.values[rating == 3 ? 2 : rating == 4 ? 3 : rating];
      
      // Calculate next review interval using SRS
      final result = _srsService.calculateNextReview(
        currentEaseFactor: currentCard!.easeFactor,
        currentIntervalDays: currentCard!.intervalDays,
        currentRepetitions: currentCard!.repetitions,
        rating: ratingEnum,
        now: DateTime.now(),
      );

      // Update card in database
      await _cardRepository.updateSrsFields(
        cardUuid: currentCard!.uuid,
        nextReviewDate: result.nextReviewDate,
        easeFactor: result.nextEaseFactor,
        intervalDays: result.nextIntervalDays,
        repetitions: result.nextRepetitions,
      );

      // Track new cards studied (for daily limit)
      if (wasNewCard) {
        _newCardsStudiedInSession++;
        await _settingsService.incrementNewCardsStudied();
      }

      // Update statistics
      _ratingCounts[rating] = (_ratingCounts[rating] ?? 0) + 1;
      _totalReviewed++;

      // For "Again" rating, card might be due again today - re-add to queue
      if (rating == 0 && result.nextIntervalDays == 0) {
        // Card is still due now, add it back to the end of the queue
        final updatedCard = currentCard!.copyWith(
          easeFactor: result.nextEaseFactor,
          intervalDays: result.nextIntervalDays,
          repetitions: result.nextRepetitions,
          nextReviewDate: result.nextReviewDate,
        );
        _dueCards.add(updatedCard);
      }

      // Move to next card and show its front side
      _currentIndex++;
      _displayedCardIndex = _currentIndex;
      _showBack = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to rate card: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Calculate next intervals for each rating option
  Map<int, String> getNextIntervals() {
    if (currentCard == null) {
      return {0: 'Soon', 1: '1d', 3: '3d', 4: '7d'};
    }

    final intervals = <int, String>{};
    final ratingMap = {0: Rating.again, 1: Rating.hard, 3: Rating.good, 4: Rating.easy};
    final now = DateTime.now();

    for (final entry in ratingMap.entries) {
      final result = _srsService.calculateNextReview(
        currentEaseFactor: currentCard!.easeFactor,
        currentIntervalDays: currentCard!.intervalDays,
        currentRepetitions: currentCard!.repetitions,
        rating: entry.value,
        now: now,
      );

      intervals[entry.key] = SrsService.formatInterval(
        result.nextIntervalDays,
        referenceDate: now,
      );
    }

    return intervals;
  }

  /// Reset the session
  void resetSession() {
    _dueCards.clear();
    _currentIndex = 0;
    _displayedCardIndex = 0;
    _showBack = false;
    _error = null;
    _ratingCounts.clear();
    _ratingCounts.addAll({0: 0, 1: 0, 3: 0, 4: 0});
    _sessionStartTime = null;
    _totalReviewed = 0;
    _newCardsStudiedInSession = 0;
    notifyListeners();
  }

  /// Update the start offset (startAtSecond) for the current card
  Future<void> updateCardOffset(int newOffset) async {
    if (currentCard == null) return;

    try {
      // Update the card's start time in local state
      final updatedCard = currentCard!.copyWith(
        startAtSecond: newOffset,
        updatedAt: DateTime.now(),
      );

      // Update in database via repository
      await _cardRepository.save(updatedCard);

      // Update the card in the current session
      _dueCards[_displayedCardIndex] = updatedCard;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update card offset: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }
}
