import '../domain/value_objects/rating.dart';

class SrsService {
  const SrsService();

  /// Calculates next review scheduling based on SM-2.
  ///
  /// Details are specified in docs/product/requirements/core/SRS.md.
  ReviewResult calculateNextReview({
    required int currentIntervalDays,
    required double currentEaseFactor,
    required int currentRepetitions,
    required Rating rating,
    required DateTime now,
  }) {
    // Implementation will be added when SRS-001 is started.
    throw UnimplementedError('Implement SM-2 scheduling when needed');
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
