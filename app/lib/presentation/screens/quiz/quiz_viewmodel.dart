import 'package:flutter/foundation.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/repositories/card_repository.dart';
import '../../../domain/value_objects/rating.dart';
import '../../../services/srs_service.dart';

/// View model for managing quiz/review session state.
/// 
/// **Features:**
/// - @DUEQUEUE-001 (Due Cards Retrieval)
/// - @DUEQUEUE-002 (Review Session Management)
class QuizViewModel extends ChangeNotifier {
  final CardRepository _cardRepository;
  final SrsService _srsService;

  QuizViewModel({
    required CardRepository cardRepository,
    required SrsService srsService,
  })  : _cardRepository = cardRepository,
        _srsService = srsService;

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

  // Getters
  List<Flashcard> get dueCards => _dueCards;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showBack => _showBack;
  
  Flashcard? get currentCard =>
      _dueCards.isNotEmpty && _displayedCardIndex < _dueCards.length
          ? _dueCards[_displayedCardIndex]
          : null;

  int get totalCards => _dueCards.length;
  int get remainingCards => _dueCards.length - _currentIndex;
  double get progress =>
      _dueCards.isEmpty ? 0.0 : _currentIndex / _dueCards.length;
  
  bool get isSessionComplete => _currentIndex >= _dueCards.length;

  Map<int, int> get ratingCounts => Map.unmodifiable(_ratingCounts);
  int get totalReviewed =>
      _ratingCounts.values.fold(0, (sum, count) => sum + count);

  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// Load due cards and start a new session
  Future<void> loadDueCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dueCards = await _cardRepository.fetchDueCards();
      _currentIndex = 0;
      _displayedCardIndex = 0;
      _showBack = false;
      _ratingCounts.clear();
      _ratingCounts.addAll({0: 0, 1: 0, 3: 0, 4: 0});
      _sessionStartTime = DateTime.now();
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

      // Update statistics
      _ratingCounts[rating] = (_ratingCounts[rating] ?? 0) + 1;

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

    for (final entry in ratingMap.entries) {
      final result = _srsService.calculateNextReview(
        currentEaseFactor: currentCard!.easeFactor,
        currentIntervalDays: currentCard!.intervalDays,
        currentRepetitions: currentCard!.repetitions,
        rating: entry.value,
        now: DateTime.now(),
      );

      intervals[entry.key] = _formatInterval(result.nextIntervalDays);
    }

    return intervals;
  }

  String _formatInterval(int days) {
    if (days == 0) return 'Soon';
    if (days == 1) return '1d';
    return '${days}d';
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
    notifyListeners();
  }
}
