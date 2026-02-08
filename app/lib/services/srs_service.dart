import '../domain/value_objects/rating.dart';

/// Service implementing the SuperMemo-2 (SM-2) algorithm for spaced repetition.
///
/// Based on requirements in docs/product/requirements/core/SRS.md
/// 
/// Algorithm Summary:
/// - Again (0): Reset to learning mode (interval=0, repetitions=0)
/// - Hard (1): Shorter interval (1.2x), ease factor decreased by 0.15
/// - Good (3): Standard SM-2 intervals, ease factor unchanged
/// - Easy (4): Longer interval (1.3x standard), ease factor increased by 0.15
///
/// Ease Factor: starts at 2.5, minimum 1.3, no upper limit
/// Intervals: First review = 1 day, second = 6 days, then multiply by ease factor
class SrsService {
  /// Minimum allowed ease factor per SM-2 specification
  static const double minEaseFactor = 1.3;
  
  /// Default ease factor for new cards
  static const double defaultEaseFactor = 2.5;
  
  /// Maximum interval cap in days (default: 1 year)
  static const int maxIntervalDays = 365;

  const SrsService();

  /// Calculates next review scheduling based on SM-2 algorithm.
  ///
  /// Parameters:
  /// - [currentIntervalDays]: Current interval in days
  /// - [currentEaseFactor]: Current ease factor (typically 1.3-4.0)
  /// - [currentRepetitions]: Number of consecutive successful reviews
  /// - [rating]: User's performance rating (Again, Hard, Good, Easy)
  /// - [now]: Current timestamp for calculating next review date
  ///
  /// Returns [ReviewResult] with updated SRS parameters
  ReviewResult calculateNextReview({
    required int currentIntervalDays,
    required double currentEaseFactor,
    required int currentRepetitions,
    required Rating rating,
    required DateTime now,
  }) {
    int nextIntervalDays;
    double nextEaseFactor;
    int nextRepetitions;

    switch (rating) {
      case Rating.again:
        // Failed recall: reset to learning mode
        nextIntervalDays = 0;
        nextRepetitions = 0;
        nextEaseFactor = currentEaseFactor; // Ease factor unchanged on failure
        break;

      case Rating.hard:
        // Difficult recall: shorter interval, decrease ease factor
        nextIntervalDays = _calculateHardInterval(currentIntervalDays);
        nextRepetitions = currentRepetitions; // Don't increment on hard
        nextEaseFactor = _adjustEaseFactor(currentEaseFactor, -0.15);
        break;

      case Rating.good:
        // Standard recall: SM-2 intervals, ease factor unchanged
        nextIntervalDays = _calculateGoodInterval(
          currentRepetitions,
          currentIntervalDays,
          currentEaseFactor,
        );
        nextRepetitions = currentRepetitions + 1;
        nextEaseFactor = currentEaseFactor;
        break;

      case Rating.easy:
        // Easy recall: longer interval, increase ease factor
        nextIntervalDays = _calculateEasyInterval(
          currentRepetitions,
          currentIntervalDays,
          currentEaseFactor,
        );
        nextRepetitions = currentRepetitions + 1;
        nextEaseFactor = _adjustEaseFactor(currentEaseFactor, 0.15);
        break;
    }

    // Apply maximum interval cap
    if (nextIntervalDays > maxIntervalDays) {
      nextIntervalDays = maxIntervalDays;
    }

    // Calculate next review date
    final nextReviewDate = now.add(Duration(days: nextIntervalDays));

    return ReviewResult(
      nextIntervalDays: nextIntervalDays,
      nextEaseFactor: nextEaseFactor,
      nextRepetitions: nextRepetitions,
      nextReviewDate: nextReviewDate,
    );
  }

  /// Calculates interval for "Hard" rating (shorter than standard)
  int _calculateHardInterval(int currentIntervalDays) {
    if (currentIntervalDays == 0) {
      return 0; // Stay at 0 if never reviewed successfully
    }
    // Use 1.2 multiplier for hard cards (shorter interval)
    return (currentIntervalDays * 1.2).round().clamp(1, maxIntervalDays);
  }

  /// Format interval in days to human-readable string
  /// 
  /// Formats:
  /// - "<1m" = Less than 1 minute (0 days)
  /// - "Xh" = Hours (< 1 day)
  /// - "Xd" = Days (1-29)
  /// - "Xw" = Weeks (30-89 days)
  /// - "Xmo" = Months (90-364 days)
  /// - Date string for 365+ days
  static String formatInterval(int days, {DateTime? referenceDate}) {
    if (days == 0) return '<1m';
    
    if (days < 7) {
      return '${days}d';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '${weeks}w';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '${months}mo';
    } else {
      // For long intervals, show absolute date
      final targetDate = (referenceDate ?? DateTime.now()).add(Duration(days: days));
      return '${_monthName(targetDate.month)} ${targetDate.day}, ${targetDate.year}';
    }
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  /// Calculates interval for "Good" rating (standard SM-2)
  int _calculateGoodInterval(
    int repetitions,
    int currentIntervalDays,
    double easeFactor,
  ) {
    if (repetitions == 0) {
      return 1; // First review: 1 day
    } else if (repetitions == 1) {
      return 6; // Second review: 6 days
    } else {
      // Subsequent reviews: multiply previous interval by ease factor
      return (currentIntervalDays * easeFactor).round().clamp(1, maxIntervalDays);
    }
  }

  /// Calculates interval for "Easy" rating (longer than standard)
  int _calculateEasyInterval(
    int repetitions,
    int currentIntervalDays,
    double easeFactor,
  ) {
    if (repetitions == 0) {
      return 4; // First review: 4 days (longer than Good)
    } else if (repetitions == 1) {
      return 10; // Second review: 10 days (longer than Good's 6)
    } else {
      // Subsequent reviews: multiply by ease factor × 1.3 bonus
      return (currentIntervalDays * easeFactor * 1.3)
          .round()
          .clamp(1, maxIntervalDays);
    }
  }

  /// Adjusts ease factor and ensures it stays within valid range
  double _adjustEaseFactor(double currentEaseFactor, double adjustment) {
    final newEaseFactor = currentEaseFactor + adjustment;
    // Minimum is 1.3, no maximum (but typically won't exceed ~4.0)
    return newEaseFactor < minEaseFactor ? minEaseFactor : newEaseFactor;
  }
}

class ReviewResult {
  final int nextIntervalDays;
  final double nextEaseFactor;
  final int nextRepetitions;
  final DateTime nextReviewDate;

  const ReviewResult({
    required this.nextIntervalDays,
    required this.nextEaseFactor,
    required this.nextRepetitions,
    required this.nextReviewDate,
  });
}
