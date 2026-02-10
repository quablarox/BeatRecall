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
  List<Flashcard> _sessionCards = []; // All cards in the session (sorted by due date)
  List<Flashcard> _availableNewCards = []; // Pool of new cards to draw from
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
  List<Flashcard> get dueCards => _sessionCards;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showBack => _showBack;
  int get newCardsStudiedInSession => _newCardsStudiedInSession;
  
  Flashcard? get currentCard {
    if (_sessionCards.isEmpty || _displayedCardIndex >= _sessionCards.length) {
      return null;
    }
    return _sessionCards[_displayedCardIndex];
  }

  int get totalCards => _sessionCards.length + _availableNewCards.length;
  int get remainingCards => _sessionCards.length - _currentIndex + _availableNewCards.length;
  double get progress => _totalReviewed == 0 ? 0.0 : _currentIndex / (_totalReviewed + remainingCards);
  
  bool get isSessionComplete => _currentIndex >= _sessionCards.length && _availableNewCards.isEmpty;

  Map<int, int> get ratingCounts => Map.unmodifiable(_ratingCounts);
  int get totalReviewed => _totalReviewed; // Use tracked total instead of sum

  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// Load due cards and optionally new cards, then start a new session
  /// 
  /// Cards are sorted by nextReviewDate for deterministic ordering.
  /// New cards are added to a pool and drawn from when no due cards are ready.
  Future<void> loadDueCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      
      // Fetch all due review cards (cards with repetitions > 0 and nextReviewDate <= now)
      final dueReviews = await _cardRepository.fetchDueCards();
      
      // Fetch new cards up to daily limit and store in pool
      final remainingNewCards = _settingsService.getRemainingNewCardsToday();
      _availableNewCards = [];
      
      if (remainingNewCards > 0) {
        final allCards = await _cardRepository.fetchAllCards();
        // New cards are those with repetitions == 0, sorted by creation date for consistency
        _availableNewCards = allCards
            .where((card) => card.repetitions == 0)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _availableNewCards = _availableNewCards.take(remainingNewCards).toList();
      }

      // Start with currently due cards, sorted by nextReviewDate then UUID for deterministic order
      _sessionCards = List.from(dueReviews)
        ..sort((a, b) {
          final dateCompare = a.nextReviewDate.compareTo(b.nextReviewDate);
          return dateCompare != 0 ? dateCompare : a.uuid.compareTo(b.uuid);
        });
      
      // Add initial new cards if no due cards
      _fillSessionWithNewCards(now);
      
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
  
  /// Fill session with new cards if no cards are currently due
  void _fillSessionWithNewCards(DateTime now) {
    // Count how many cards are actually due right now
    final dueNow = _sessionCards.where((card) => card.nextReviewDate.isBefore(now) || card.nextReviewDate.isAtSameMomentAs(now)).length;
    
    // If we have capacity and new cards available, add them
    while (dueNow < 1 && _availableNewCards.isNotEmpty) {
      final newCard = _availableNewCards.removeAt(0);
      // New cards are considered due immediately
      _sessionCards.add(newCard.copyWith(nextReviewDate: now));
    }
    
    // Re-sort after adding new cards
    _sessionCards.sort((a, b) {
      final dateCompare = a.nextReviewDate.compareTo(b.nextReviewDate);
      return dateCompare != 0 ? dateCompare : a.uuid.compareTo(b.uuid);
    });
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
      final now = DateTime.now();
      
      // Save reference to current card before we modify the list
      final cardToRate = currentCard!;
      
      // Track if this was a new card
      final wasNewCard = cardToRate.repetitions == 0;
      
      // Convert int rating to Rating enum
      final ratingEnum = Rating.values[rating == 3 ? 2 : rating == 4 ? 3 : rating];
      
      // Calculate next review interval using SRS
      final result = _srsService.calculateNextReview(
        currentEaseFactor: cardToRate.easeFactor,
        currentIntervalMinutes: cardToRate.intervalMinutes,
        currentRepetitions: cardToRate.repetitions,
        rating: ratingEnum,
        now: now,
      );

      // Update card in database
      await _cardRepository.updateSrsFields(
        cardUuid: cardToRate.uuid,
        nextReviewDate: result.nextReviewDate,
        easeFactor: result.nextEaseFactor,
        intervalMinutes: result.nextIntervalMinutes,
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

      // Update the card in place with new SRS data
      final updatedCard = cardToRate.copyWith(
        easeFactor: result.nextEaseFactor,
        intervalMinutes: result.nextIntervalMinutes,
        repetitions: result.nextRepetitions,
        nextReviewDate: result.nextReviewDate,
      );
      _sessionCards[_displayedCardIndex] = updatedCard;

      // If card is due again in this session (within 24 hours), add to end of queue
      if (result.nextIntervalMinutes < 1440) {
        _sessionCards.add(updatedCard);
      }

      // Move to next card
      _currentIndex++;
      
      // Skip cards that aren't due yet and try to fill with new cards
      _advanceToNextDueCard(now);
      
      _displayedCardIndex = _currentIndex;
      _showBack = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to rate card: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }
  
  /// Advance to the next card that is actually due, or add a new card if available
  void _advanceToNextDueCard(DateTime now) {
    // Skip cards that aren't due yet
    while (_currentIndex < _sessionCards.length && 
           _sessionCards[_currentIndex].nextReviewDate.isAfter(now)) {
      // Try to insert a new card before this not-yet-due card
      if (_availableNewCards.isNotEmpty) {
        final newCard = _availableNewCards.removeAt(0);
        // Insert new card with current time as due date
        _sessionCards.insert(_currentIndex, newCard.copyWith(nextReviewDate: now));
        // New card is now at _currentIndex, so it will be shown
        return;
      }
      // No new cards available - stop here and wait for this card to become due
      // Don't increment past it
      return;
    }
    
    // If we've gone through all session cards and none are due, add a new card if available
    if (_currentIndex >= _sessionCards.length && _availableNewCards.isNotEmpty) {
      final newCard = _availableNewCards.removeAt(0);
      _sessionCards.add(newCard.copyWith(nextReviewDate: now));
    }
  }

  /// Calculate next intervals for each rating option
  Map<int, String> getNextIntervals() {
    if (currentCard == null) {
      return {0: '1m', 1: '10m', 3: '1d', 4: '4d'};
    }

    final intervals = <int, String>{};
    final ratingMap = {0: Rating.again, 1: Rating.hard, 3: Rating.good, 4: Rating.easy};
    final now = DateTime.now();

    for (final entry in ratingMap.entries) {
      final result = _srsService.calculateNextReview(
        currentEaseFactor: currentCard!.easeFactor,
        currentIntervalMinutes: currentCard!.intervalMinutes,
        currentRepetitions: currentCard!.repetitions,
        rating: entry.value,
        now: now,
      );

      intervals[entry.key] = SrsService.formatInterval(
        result.nextIntervalMinutes,
        referenceDate: now,
      );
    }

    return intervals;
  }

  /// Reset the session
  void resetSession() {
    _sessionCards.clear();
    _availableNewCards.clear();
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
      _sessionCards[_displayedCardIndex] = updatedCard;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update card offset: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }
}
