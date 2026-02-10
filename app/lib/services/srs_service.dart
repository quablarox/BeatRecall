import '../domain/value_objects/rating.dart';

/// Service implementing a modified SuperMemo-2 (SM-2) algorithm with Anki-like granular intervals.
///
/// Based on requirements in docs/product/requirements/core/SRS.md
/// 
/// Algorithm Summary:
/// - Again (0): Back to learning (1 minute)
/// - Hard (1): Shorter interval, ease factor decreased by 0.15
/// - Good (3): Standard learning/review progression
/// - Easy (4): Skip learning, longer intervals, increase ease factor
///
/// Learning progression (Anki-style):
/// - Rep 0 (new): Again=1m, Hard=10m, Good=1d, Easy=4d
/// - Rep 1 (learning): Again=1m, Hard=10m, Good=3d (graduate), Easy=7d (graduate)
/// - Rep 2 (first review): Good=interval×ease, Easy=interval×ease×1.3
/// - Rep 3+ (review): Good=interval×ease, Easy=interval×ease×1.3
///
/// Ease Factor: starts at 2.5, minimum 1.3, no upper limit
/// Time units: All intervals stored in minutes
class SrsService {
  /// Minimum allowed ease factor per SM-2 specification
  static const double minEaseFactor = 1.3;
  
  /// Default ease factor for new cards
  static const double defaultEaseFactor = 2.5;
  
  /// Maximum interval cap in minutes (default: 1 year = 525,600 minutes)
  static const int maxIntervalMinutes = 365 * 24 * 60;
  
  /// Learning step 1: 1 minute (for Again on new cards)
  static const int learningStep1Minutes = 1;
  
  /// Learning step 2: 10 minutes (for Good/Hard on new cards)
  static const int learningStep2Minutes = 10;
  
  /// Graduating interval: 1 day (1440 minutes)
  static const int graduatingIntervalMinutes = 24 * 60;
  
  /// Easy graduating interval: 4 days (5760 minutes)
  static const int easyGraduatingIntervalMinutes = 4 * 24 * 60;

  const SrsService();

  /// Calculates next review scheduling based on SM-2 algorithm with minute-based intervals.
  ///
  /// Parameters:
  /// - [currentIntervalMinutes]: Current interval in minutes
  /// - [currentEaseFactor]: Current ease factor (typically 1.3-4.0)
  /// - [currentRepetitions]: Number of consecutive successful reviews
  /// - [rating]: User's performance rating (Again, Hard, Good, Easy)
  /// - [now]: Current timestamp for calculating next review date
  ///
  /// Returns [ReviewResult] with updated SRS parameters
  ReviewResult calculateNextReview({
    required int currentIntervalMinutes,
    required double currentEaseFactor,
    required int currentRepetitions,
    required Rating rating,
    required DateTime now,
  }) {
    int nextIntervalMinutes;
    double nextEaseFactor;
    int nextRepetitions;

    switch (rating) {
      case Rating.again:
        // Failed recall: back to learning step 1
        nextIntervalMinutes = learningStep1Minutes; // 1 minute
        nextRepetitions = 0;
        // Penalize ease factor slightly on failure for young cards
        nextEaseFactor = currentRepetitions < 3 
            ? _adjustEaseFactor(currentEaseFactor, -0.2)
            : currentEaseFactor;
        break;

      case Rating.hard:
        // Difficult recall: shorter interval, decrease ease factor
        nextIntervalMinutes = _calculateHardInterval(currentIntervalMinutes, currentRepetitions);
        nextRepetitions = currentRepetitions; // Don't increment on hard
        nextEaseFactor = _adjustEaseFactor(currentEaseFactor, -0.15);
        break;

      case Rating.good:
        // Standard recall: learning progression or SM-2 intervals
        nextIntervalMinutes = _calculateGoodInterval(
          currentRepetitions,
          currentIntervalMinutes,
          currentEaseFactor,
        );
        nextRepetitions = currentRepetitions + 1;
        nextEaseFactor = currentEaseFactor;
        break;

      case Rating.easy:
        // Easy recall: skip learning, longer intervals, increase ease factor
        nextIntervalMinutes = _calculateEasyInterval(
          currentRepetitions,
          currentIntervalMinutes,
          currentEaseFactor,
        );
        nextRepetitions = currentRepetitions + 1;
        nextEaseFactor = _adjustEaseFactor(currentEaseFactor, 0.15);
        break;
    }

    // Apply maximum interval cap
    if (nextIntervalMinutes > maxIntervalMinutes) {
      nextIntervalMinutes = maxIntervalMinutes;
    }

    // Calculate next review date
    final nextReviewDate = now.add(Duration(minutes: nextIntervalMinutes));

    return ReviewResult(
      nextIntervalMinutes: nextIntervalMinutes,
      nextEaseFactor: nextEaseFactor,
      nextRepetitions: nextRepetitions,
      nextReviewDate: nextReviewDate,
    );
  }

  /// Calculates interval for "Hard" rating (shorter than standard)
  int _calculateHardInterval(int currentIntervalMinutes, int repetitions) {
    if (repetitions == 0) {
      // New cards: stay in learning step 2 (10 minutes)
      return learningStep2Minutes;
    }
    
    if (repetitions == 1) {
      // Learning cards: repeat the same step (10 minutes or current interval)
      return currentIntervalMinutes < graduatingIntervalMinutes 
          ? learningStep2Minutes 
          : currentIntervalMinutes;
    }
    
    // Review cards: use 1.2 multiplier (shorter interval)
    return (currentIntervalMinutes * 1.2).round().clamp(graduatingIntervalMinutes, maxIntervalMinutes);
  }

  /// Format interval in minutes to human-readable string (Anki-style)
  /// 
  /// Formats:
  /// - "Xm" = Minutes (< 60 minutes)
  /// - "Xh" = Hours (60 minutes to < 24 hours)
  /// - "Xd" = Days (1-29 days)
  /// - "Xw" = Weeks (30-364 days)
  /// - "Xmo" = Months (365+ days, < 2 years)
  /// - Date string for very long intervals
  static String formatInterval(int minutes, {DateTime? referenceDate}) {
    if (minutes < 1) return '<1m';
    
    if (minutes < 60) {
      // Less than 1 hour: show minutes
      return '${minutes}m';
    } else if (minutes < 1440) {
      // Less than 1 day: show hours
      final hours = (minutes / 60).round();
      return '${hours}h';
    } else if (minutes < 10080) {
      // Less than 7 days: show days
      final days = (minutes / 1440).round();
      return '${days}d';
    } else if (minutes < 525600) {
      // Less than 1 year: show weeks or months
      final days = (minutes / 1440).round();
      if (days < 30) {
        final weeks = (days / 7).floor();
        return '${weeks}w';
      } else {
        final months = (days / 30).floor();
        return '${months}mo';
      }
    } else {
      // For long intervals, show absolute date
      final targetDate = (referenceDate ?? DateTime.now()).add(Duration(minutes: minutes));
      return '${_monthName(targetDate.month)} ${targetDate.day}, ${targetDate.year}';
    }
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  /// Calculates interval for "Good" rating with Anki-style learning steps
  int _calculateGoodInterval(
    int repetitions,
    int currentIntervalMinutes,
    double easeFactor,
  ) {
    if (repetitions == 0) {
      // New cards: 1 day (better than Hard's 10 minutes)
      return graduatingIntervalMinutes;
    } else if (repetitions == 1) {
      // Graduate with first review: 3 days
      return 3 * graduatingIntervalMinutes;
    } else {
      // Review cards: multiply previous interval by ease factor
      return (currentIntervalMinutes * easeFactor).round().clamp(graduatingIntervalMinutes, maxIntervalMinutes);
    }
  }

  /// Calculates interval for "Easy" rating (skip learning, longer intervals)
  int _calculateEasyInterval(
    int repetitions,
    int currentIntervalMinutes,
    double easeFactor,
  ) {
    if (repetitions == 0) {
      // New cards: skip learning, graduate to 4 days immediately
      return easyGraduatingIntervalMinutes;
    } else if (repetitions == 1) {
      // Graduate with bonus: 7 days
      return 7 * graduatingIntervalMinutes;
    } else {
      // Review cards: multiply by ease factor × 1.3 bonus
      return (currentIntervalMinutes * easeFactor * 1.3)
          .round()
          .clamp(graduatingIntervalMinutes, maxIntervalMinutes);
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
  final int nextIntervalMinutes;
  final double nextEaseFactor;
  final int nextRepetitions;
  final DateTime nextReviewDate;

  const ReviewResult({
    required this.nextIntervalMinutes,
    required this.nextEaseFactor,
    required this.nextRepetitions,
    required this.nextReviewDate,
  });
}
