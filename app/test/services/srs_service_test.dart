import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/services/srs_service.dart';
import 'package:beat_recall/domain/value_objects/rating.dart';

/// Comprehensive tests for SM-2 algorithm implementation
/// 
/// Test coverage for SRS-001: SM-2 Algorithm Implementation
/// Based on requirements in docs/product/requirements/core/SRS.md
void main() {
  group('SrsService - SM-2 Algorithm (@SRS-001)', () {
    late SrsService service;
    late DateTime baseTime;

    setUp(() {
      service = const SrsService();
      baseTime = DateTime(2026, 2, 8, 10, 0, 0);
    });

    group('Rating.again (Failed Recall)', () {
      test('resets interval to 0 for new card', () {
        // Given: A new card (repetitions=0, interval=0)
        final result = service.calculateNextReview(
          currentIntervalDays: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Card stays at interval 0
        expect(result.nextIntervalDays, 0);
        expect(result.nextRepetitions, 0);
        expect(result.nextEaseFactor, 2.5); // Unchanged
        expect(result.nextReviewDate, baseTime); // Now + 0 days
      });

      test('resets interval and repetitions for card in learning phase', () {
        // Given: Card with 10-day interval and 2 repetitions
        final result = service.calculateNextReview(
          currentIntervalDays: 10,
          currentEaseFactor: 2.5,
          currentRepetitions: 2,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Everything resets
        expect(result.nextIntervalDays, 0);
        expect(result.nextRepetitions, 0);
        expect(result.nextEaseFactor, 2.5); // Ease factor unchanged on failure
      });

      test('resets mature card to learning mode', () {
        // Given: Mature card (high interval, many repetitions)
        final result = service.calculateNextReview(
          currentIntervalDays: 120,
          currentEaseFactor: 2.8,
          currentRepetitions: 10,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Card resets completely
        expect(result.nextIntervalDays, 0);
        expect(result.nextRepetitions, 0);
        expect(result.nextEaseFactor, 2.8);
      });
    });

    group('Rating.hard (Difficult Recall)', () {
      test('calculates shorter interval for first review', () {
        // Given: New card just reviewed once (interval=1)
        final result = service.calculateNextReview(
          currentIntervalDays: 1,
          currentEaseFactor: 2.5,
          currentRepetitions: 1,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval = 1 * 1.2 = 1.2 → 1 day
        expect(result.nextIntervalDays, 1);
        expect(result.nextRepetitions, 1); // Repetitions don't increase
        expect(result.nextEaseFactor, 2.35); // 2.5 - 0.15 = 2.35
      });

      test('applies 1.2 multiplier to current interval', () {
        // Given: Card with 10-day interval
        final result = service.calculateNextReview(
          currentIntervalDays: 10,
          currentEaseFactor: 2.5,
          currentRepetitions: 3,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval = 10 * 1.2 = 12 days
        expect(result.nextIntervalDays, 12);
        expect(result.nextRepetitions, 3); // Don't increment
      });

      test('decreases ease factor by 0.15', () {
        // Given: Card with ease factor 2.5
        final result = service.calculateNextReview(
          currentIntervalDays: 10,
          currentEaseFactor: 2.5,
          currentRepetitions: 2,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Ease factor = 2.5 - 0.15 = 2.35
        expect(result.nextEaseFactor, 2.35);
      });

      test('enforces minimum ease factor of 1.3', () {
        // Given: Card with ease factor already at 1.4
        final result = service.calculateNextReview(
          currentIntervalDays: 5,
          currentEaseFactor: 1.4,
          currentRepetitions: 2,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Ease factor = max(1.4 - 0.15, 1.3) = 1.3
        expect(result.nextEaseFactor, 1.3);
      });

      test('keeps interval at 0 if not yet reviewed successfully', () {
        // Given: Card with interval=0 (never reviewed successfully)
        final result = service.calculateNextReview(
          currentIntervalDays: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval stays at 0
        expect(result.nextIntervalDays, 0);
      });
    });

    group('Rating.good (Standard Recall)', () {
      test('sets first review interval to 1 day', () {
        // Given: New card (repetitions=0)
        final result = service.calculateNextReview(
          currentIntervalDays: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: First review = 1 day
        expect(result.nextIntervalDays, 1);
        expect(result.nextRepetitions, 1);
        expect(result.nextEaseFactor, 2.5); // Unchanged
        expect(result.nextReviewDate, baseTime.add(const Duration(days: 1)));
      });

      test('sets second review interval to 6 days', () {
        // Given: Card after first review (repetitions=1)
        final result = service.calculateNextReview(
          currentIntervalDays: 1,
          currentEaseFactor: 2.5,
          currentRepetitions: 1,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Second review = 6 days
        expect(result.nextIntervalDays, 6);
        expect(result.nextRepetitions, 2);
        expect(result.nextEaseFactor, 2.5);
      });

      test('multiplies interval by ease factor for subsequent reviews', () {
        // Given: Card after second review (repetitions=2, interval=6)
        final result = service.calculateNextReview(
          currentIntervalDays: 6,
          currentEaseFactor: 2.5,
          currentRepetitions: 2,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = 6 * 2.5 = 15 days
        expect(result.nextIntervalDays, 15);
        expect(result.nextRepetitions, 3);
      });

      test('continues SM-2 progression with custom ease factor', () {
        // Given: Card with ease factor 2.0, interval 20
        final result = service.calculateNextReview(
          currentIntervalDays: 20,
          currentEaseFactor: 2.0,
          currentRepetitions: 5,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = 20 * 2.0 = 40 days
        expect(result.nextIntervalDays, 40);
        expect(result.nextRepetitions, 6);
        expect(result.nextEaseFactor, 2.0);
      });

      test('keeps ease factor unchanged', () {
        // Given: Any card rated "Good"
        final result = service.calculateNextReview(
          currentIntervalDays: 10,
          currentEaseFactor: 2.7,
          currentRepetitions: 3,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Ease factor remains the same
        expect(result.nextEaseFactor, 2.7);
      });
    });

    group('Rating.easy (Easy Recall)', () {
      test('sets first review interval to 4 days', () {
        // Given: New card (repetitions=0)
        final result = service.calculateNextReview(
          currentIntervalDays: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: First review = 4 days (longer than Good's 1)
        expect(result.nextIntervalDays, 4);
        expect(result.nextRepetitions, 1);
        expect(result.nextEaseFactor, 2.65); // 2.5 + 0.15
      });

      test('sets second review interval to 10 days', () {
        // Given: Card after first review (repetitions=1, interval=4)
        final result = service.calculateNextReview(
          currentIntervalDays: 4,
          currentEaseFactor: 2.65,
          currentRepetitions: 1,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Second review = 10 days (longer than Good's 6)
        expect(result.nextIntervalDays, 10);
        expect(result.nextRepetitions, 2);
        expect(result.nextEaseFactor, 2.8); // 2.65 + 0.15
      });

      test('multiplies interval by ease factor × 1.3 for subsequent reviews', () {
        // Given: Card after second review (repetitions=2, interval=10)
        final result = service.calculateNextReview(
          currentIntervalDays: 10,
          currentEaseFactor: 2.8,
          currentRepetitions: 2,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Interval = 10 * 2.8 * 1.3 = 36.4 → 36 days
        expect(result.nextIntervalDays, 36);
        expect(result.nextRepetitions, 3);
      });

      test('increases ease factor by 0.15', () {
        // Given: Card with ease factor 2.5
        final result = service.calculateNextReview(
          currentIntervalDays: 20,
          currentEaseFactor: 2.5,
          currentRepetitions: 5,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Ease factor = 2.5 + 0.15 = 2.65
        expect(result.nextEaseFactor, 2.65);
      });

      test('allows ease factor to exceed default maximum', () {
        // Given: Card with already high ease factor (3.8)
        final result = service.calculateNextReview(
          currentIntervalDays: 50,
          currentEaseFactor: 3.8,
          currentRepetitions: 10,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Ease factor can go higher (no upper limit in SM-2)
        expect(result.nextEaseFactor, closeTo(3.95, 0.01)); // 3.8 + 0.15
      });
    });

    group('Edge Cases & Constraints', () {
      test('applies maximum interval cap of 365 days', () {
        // Given: Card with very long interval calculation
        final result = service.calculateNextReview(
          currentIntervalDays: 300,
          currentEaseFactor: 3.0,
          currentRepetitions: 15,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = min(300 * 3.0, 365) = 365
        expect(result.nextIntervalDays, 365);
      });

      test('caps easy rating interval at maximum', () {
        // Given: Easy rating that would exceed maximum
        final result = service.calculateNextReview(
          currentIntervalDays: 250,
          currentEaseFactor: 2.5,
          currentRepetitions: 10,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Interval = min(250 * 2.5 * 1.3, 365) = 365
        expect(result.nextIntervalDays, 365);
      });

      test('calculates correct next review date', () {
        // Given: Rating that results in 10-day interval
        final result = service.calculateNextReview(
          currentIntervalDays: 5,
          currentEaseFactor: 2.0,
          currentRepetitions: 2,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Next review date = baseTime + 10 days
        expect(result.nextIntervalDays, 10);
        expect(result.nextReviewDate, DateTime(2026, 2, 18, 10, 0, 0));
      });

      test('handles zero interval date calculation', () {
        // Given: Again rating resulting in 0-day interval
        final result = service.calculateNextReview(
          currentIntervalDays: 10,
          currentEaseFactor: 2.5,
          currentRepetitions: 3,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Next review date = now (same day)
        expect(result.nextReviewDate, baseTime);
      });

      test('rounds fractional intervals correctly', () {
        // Given: Calculation resulting in 1.5 days
        final result = service.calculateNextReview(
          currentIntervalDays: 1,
          currentEaseFactor: 1.5,
          currentRepetitions: 2,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: 1 * 1.5 = 1.5 → rounds to 2 days
        expect(result.nextIntervalDays, 2);
      });
    });

    group('Real-world Scenarios', () {
      test('tracks progression through learning phase', () {
        var currentInterval = 0;
        var currentEaseFactor = 2.5;
        var currentRepetitions = 0;
        var currentTime = baseTime;

        // Review 1: Good → 1 day
        var result = service.calculateNextReview(
          currentIntervalDays: currentInterval,
          currentEaseFactor: currentEaseFactor,
          currentRepetitions: currentRepetitions,
          rating: Rating.good,
          now: currentTime,
        );
        expect(result.nextIntervalDays, 1);
        expect(result.nextRepetitions, 1);

        // Review 2: Good → 6 days
        result = service.calculateNextReview(
          currentIntervalDays: result.nextIntervalDays,
          currentEaseFactor: result.nextEaseFactor,
          currentRepetitions: result.nextRepetitions,
          rating: Rating.good,
          now: currentTime.add(Duration(days: result.nextIntervalDays)),
        );
        expect(result.nextIntervalDays, 6);
        expect(result.nextRepetitions, 2);

        // Review 3: Good → 15 days (6 * 2.5)
        result = service.calculateNextReview(
          currentIntervalDays: result.nextIntervalDays,
          currentEaseFactor: result.nextEaseFactor,
          currentRepetitions: result.nextRepetitions,
          rating: Rating.good,
          now: currentTime.add(Duration(days: result.nextIntervalDays)),
        );
        expect(result.nextIntervalDays, 15);
        expect(result.nextRepetitions, 3);
      });

      test('handles ease factor degradation with multiple hard reviews', () {
        var easeFactor = 2.5;

        // Three hard reviews in a row
        for (var i = 0; i < 3; i++) {
          final result = service.calculateNextReview(
            currentIntervalDays: 10,
            currentEaseFactor: easeFactor,
            currentRepetitions: 3,
            rating: Rating.hard,
            now: baseTime,
          );
          easeFactor = result.nextEaseFactor;
        }

        // Ease factor should decrease: 2.5 → 2.35 → 2.2 → 2.05
        expect(easeFactor, closeTo(2.05, 0.01));
      });

      test('handles ease factor improvement with easy reviews', () {
        var easeFactor = 2.5;

        // Three easy reviews in a row
        for (var i = 0; i < 3; i++) {
          final result = service.calculateNextReview(
            currentIntervalDays: 10,
            currentEaseFactor: easeFactor,
            currentRepetitions: 3,
            rating: Rating.easy,
            now: baseTime,
          );
          easeFactor = result.nextEaseFactor;
        }

        // Ease factor should increase: 2.5 → 2.65 → 2.8 → 2.95
        expect(easeFactor, closeTo(2.95, 0.01));
      });
    });

    group('@FLASHSYS-005 Enhanced Interval Display', () {
      test('Given 0 days, When formatting, Then returns "<1m"', () {
        final result = SrsService.formatInterval(0);
        expect(result, '<1m');
      });

      test('Given 1 day, When formatting, Then returns "1d"', () {
        final result = SrsService.formatInterval(1);
        expect(result, '1d');
      });

      test('Given 3 days, When formatting, Then returns "3d"', () {
        final result = SrsService.formatInterval(3);
        expect(result, '3d');
      });

      test('Given 6 days, When formatting, Then returns "6d"', () {
        final result = SrsService.formatInterval(6);
        expect(result, '6d');
      });

      test('Given 7 days, When formatting, Then returns "1w"', () {
        final result = SrsService.formatInterval(7);
        expect(result, '1w');
      });

      test('Given 14 days, When formatting, Then returns "2w"', () {
        final result = SrsService.formatInterval(14);
        expect(result, '2w');
      });

      test('Given 21 days, When formatting, Then returns "3w"', () {
        final result = SrsService.formatInterval(21);
        expect(result, '3w');
      });

      test('Given 28 days, When formatting, Then returns "4w"', () {
        final result = SrsService.formatInterval(28);
        expect(result, '4w');
      });

      test('Given 30 days, When formatting, Then returns "1mo"', () {
        final result = SrsService.formatInterval(30);
        expect(result, '1mo');
      });

      test('Given 60 days, When formatting, Then returns "2mo"', () {
        final result = SrsService.formatInterval(60);
        expect(result, '2mo');
      });

      test('Given 90 days, When formatting, Then returns "3mo"', () {
        final result = SrsService.formatInterval(90);
        expect(result, '3mo');
      });

      test('Given 180 days, When formatting, Then returns "6mo"', () {
        final result = SrsService.formatInterval(180);
        expect(result, '6mo');
      });

      test('Given 364 days, When formatting, Then returns "12mo"', () {
        final result = SrsService.formatInterval(364);
        expect(result, '12mo');
      });

      test('Given 365 days, When formatting, Then returns absolute date', () {
        final referenceDate = DateTime(2025, 1, 1);
        final result = SrsService.formatInterval(365, referenceDate: referenceDate);
        
        // Expected: Jan 1, 2025 + 365 days = Jan 1, 2026
        expect(result, 'Jan 1, 2026');
      });

      test('Given 400 days, When formatting, Then returns absolute date', () {
        final referenceDate = DateTime(2025, 1, 15);
        final result = SrsService.formatInterval(400, referenceDate: referenceDate);
        
        // Expected: Jan 15, 2025 + 400 days = Feb 19, 2026
        expect(result, 'Feb 19, 2026');
      });

      test('Given 730 days, When formatting, Then returns absolute date 2 years later', () {
        final referenceDate = DateTime(2025, 3, 1);
        final result = SrsService.formatInterval(730, referenceDate: referenceDate);
        
        // Expected: Mar 1, 2025 + 730 days = Feb 29, 2027 (leap year)
        expect(result, 'Mar 1, 2027');
      });

      test('Given no reference date for large interval, When formatting, Then uses DateTime.now()', () {
        // This test just verifies it doesn't crash
        final result = SrsService.formatInterval(500);
        
        // Result should be a date string (format: "Mon DD, YYYY")
        expect(result, matches(r'\w{3} \d{1,2}, \d{4}'));
      });

      test('Given boundary cases, When formatting, Then handles correctly', () {
        expect(SrsService.formatInterval(0), '<1m');
        expect(SrsService.formatInterval(6), '6d'); // Last day before weeks
        expect(SrsService.formatInterval(7), '1w'); // First week
        expect(SrsService.formatInterval(29), '4w'); // Last week before months
        expect(SrsService.formatInterval(30), '1mo'); // First month
        expect(SrsService.formatInterval(364), '12mo'); // Last month before absolute
        
        final ref = DateTime(2025, 1, 1);
        final result365 = SrsService.formatInterval(365, referenceDate: ref);
        expect(result365, 'Jan 1, 2026'); // First absolute date
      });
    });
  });
}
