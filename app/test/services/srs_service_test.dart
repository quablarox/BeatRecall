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
      test('returns 1 minute for new card (learning step 1)', () {
        // Given: A new card (repetitions=0, interval=0)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Card goes to 1 minute (learning step 1)
        expect(result.nextIntervalMinutes, 1);
        expect(result.nextRepetitions, 0);
        expect(result.nextEaseFactor, 2.3); // Penalized by -0.2 for young card
        expect(result.nextReviewDate, baseTime.add(const Duration(minutes: 1)));
      });

      test('returns 1 minute for card in learning phase', () {
        // Given: Card with 10-day interval and 2 repetitions
        final result = service.calculateNextReview(
          currentIntervalMinutes: 14400,
          currentEaseFactor: 2.5,
          currentRepetitions: 2,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Returns to learning step 1 (1 minute)
        expect(result.nextIntervalMinutes, 1);
        expect(result.nextRepetitions, 0);
        expect(result.nextEaseFactor, 2.3); // Penalized by -0.2 for young card
      });

      test('returns 1 minute for mature card', () {
        // Given: Mature card (high interval, many repetitions)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 172800,
          currentEaseFactor: 2.8,
          currentRepetitions: 10,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Card returns to learning step 1 (1 minute)
        expect(result.nextIntervalMinutes, 1);
        expect(result.nextRepetitions, 0);
        expect(result.nextEaseFactor, 2.8); // No penalty for mature cards
      });
    });

    group('Rating.hard (Difficult Recall)', () {
      test('returns 10 minutes for new card (learning step 2)', () {
        // Given: Brand new card (repetitions=0, interval=0)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval = 10 minutes (learning step 2)
        expect(result.nextIntervalMinutes, 10);
        expect(result.nextRepetitions, 0); // Repetitions don't increase
        expect(result.nextEaseFactor, 2.35); // 2.5 - 0.15 = 2.35
      });

      test('returns same interval for graduated card (rep=1)', () {
        // Given: Graduated card (interval=1 day, rep=1)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 1440,
          currentEaseFactor: 2.5,
          currentRepetitions: 1,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval stays at 1 day (same interval for rep≥1)
        expect(result.nextIntervalMinutes, 1440);
        expect(result.nextRepetitions, 1); // Repetitions don't increase
        expect(result.nextEaseFactor, 2.35); // 2.5 - 0.15 = 2.35
      });

      test('applies 1.2 multiplier for review cards (rep≥2)', () {
        // Given: Review card with 10-day interval and rep=3
        final result = service.calculateNextReview(
          currentIntervalMinutes: 14400,
          currentEaseFactor: 2.5,
          currentRepetitions: 3,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval = 10 * 1.2 = 12 days
        expect(result.nextIntervalMinutes, 17280);
        expect(result.nextRepetitions, 3); // Don't increment
      });

      test('decreases ease factor by 0.15', () {
        // Given: Card with ease factor 2.5
        final result = service.calculateNextReview(
          currentIntervalMinutes: 14400,
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
          currentIntervalMinutes: 7200,
          currentEaseFactor: 1.4,
          currentRepetitions: 2,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Ease factor = max(1.4 - 0.15, 1.3) = 1.3
        expect(result.nextEaseFactor, 1.3);
      });

      test('gives 10 minutes for new card (different from Again)', () {
        // Given: Card with interval=0, repetitions=0 (new card)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.hard,
          now: baseTime,
        );

        // Then: Interval = 10 minutes (learning step 2, longer than Again's 1 minute)
        expect(result.nextIntervalMinutes, 10);
      });
    });

    group('Rating.good (Standard Recall)', () {
      test('returns 1 day for new card (better than Hard)', () {
        // Given: New card (repetitions=0)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = 1 day (1440 minutes), rep increments to 1
        expect(result.nextIntervalMinutes, 1440);
        expect(result.nextRepetitions, 1);
        expect(result.nextEaseFactor, 2.5); // Unchanged
        expect(result.nextReviewDate, baseTime.add(const Duration(minutes: 1440)));
      });

      test('graduates card to 3 days for rep=1', () {
        // Given: Card after first Good review (rep=1, 1 day)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 1440,
          currentEaseFactor: 2.5,
          currentRepetitions: 1,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Graduates to 3 days (rep becomes 2)
        expect(result.nextIntervalMinutes, 4320);
        expect(result.nextRepetitions, 2);
        expect(result.nextEaseFactor, 2.5);
      });

      test('applies ease factor for subsequent reviews (rep=2+)', () {
        // Given: Card at rep=2, interval=3 days
        final result = service.calculateNextReview(
          currentIntervalMinutes: 4320,
          currentEaseFactor: 2.5,
          currentRepetitions: 2,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = 3d × 2.5 = 7.5d → 10800 minutes
        expect(result.nextIntervalMinutes, 10800);
        expect(result.nextRepetitions, 3);
        expect(result.nextEaseFactor, 2.5);
      });

      test('multiplies interval by ease factor for rep≥3', () {
        // Given: Card after first review post-graduation (rep=3, interval=7.5 days)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 10800,
          currentEaseFactor: 2.5,
          currentRepetitions: 3,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = 7.5d × 2.5 = 18.75d → 27000 minutes
        expect(result.nextIntervalMinutes, 27000);
        expect(result.nextRepetitions, 4);
      });

      test('continues SM-2 progression with custom ease factor', () {
        // Given: Card with ease factor 2.0, interval 20
        final result = service.calculateNextReview(
          currentIntervalMinutes: 28800,
          currentEaseFactor: 2.0,
          currentRepetitions: 5,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = 20 * 2.0 = 40 days
        expect(result.nextIntervalMinutes, 57600);
        expect(result.nextRepetitions, 6);
        expect(result.nextEaseFactor, 2.0);
      });

      test('keeps ease factor unchanged', () {
        // Given: Any card rated "Good"
        final result = service.calculateNextReview(
          currentIntervalMinutes: 14400,
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
      test('skips learning and graduates to 4 days for new card', () {
        // Given: New card (repetitions=0)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 0,
          currentEaseFactor: 2.5,
          currentRepetitions: 0,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Skip learning, graduate to 4 days
        expect(result.nextIntervalMinutes, 5760);
        expect(result.nextRepetitions, 1);
        expect(result.nextEaseFactor, 2.65); // 2.5 + 0.15
      });

      test('graduates with bonus to 7 days for rep=1', () {
        // Given: Card at learning step 2 (rep=1, 10 minutes)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 10,
          currentEaseFactor: 2.5,
          currentRepetitions: 1,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Graduate with bonus to 7 days
        expect(result.nextIntervalMinutes, 10080);
        expect(result.nextRepetitions, 2);
        expect(result.nextEaseFactor, 2.65); // 2.5 + 0.15
      });

      test('multiplies interval by ease factor × 1.3 for rep≥2', () {
        // Given: Review card post-graduation (rep=2, interval=7 days)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 10080,
          currentEaseFactor: 2.65,
          currentRepetitions: 2,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Interval = 7 * 2.65 * 1.3 = 24.505 → 24683 minutes (rounded)
        expect(result.nextIntervalMinutes, closeTo(34726, 1));
        expect(result.nextRepetitions, 3);
      });

      test('increases ease factor by 0.15', () {
        // Given: Card with ease factor 2.5
        final result = service.calculateNextReview(
          currentIntervalMinutes: 28800,
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
          currentIntervalMinutes: 72000,
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
          currentIntervalMinutes: 432000,
          currentEaseFactor: 3.0,
          currentRepetitions: 15,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Interval = min(300 * 3.0, 365) = 365
        expect(result.nextIntervalMinutes, 525600);
      });

      test('caps easy rating interval at maximum', () {
        // Given: Easy rating that would exceed maximum
        final result = service.calculateNextReview(
          currentIntervalMinutes: 360000,
          currentEaseFactor: 2.5,
          currentRepetitions: 10,
          rating: Rating.easy,
          now: baseTime,
        );

        // Then: Interval = min(250 * 2.5 * 1.3, 365) = 365
        expect(result.nextIntervalMinutes, 525600);
      });

      test('calculates correct next review date', () {
        // Given: Rating that results in 3-day interval (rep=1 with Good)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 1440,
          currentEaseFactor: 2.0,
          currentRepetitions: 1,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: Next review date = baseTime + 3 days
        expect(result.nextIntervalMinutes, 4320);
        expect(result.nextReviewDate, DateTime(2026, 2, 11, 10, 0, 0));
      });

      test('handles 1-minute interval date calculation', () {
        // Given: Again rating resulting in 1-minute interval
        final result = service.calculateNextReview(
          currentIntervalMinutes: 14400,
          currentEaseFactor: 2.5,
          currentRepetitions: 3,
          rating: Rating.again,
          now: baseTime,
        );

        // Then: Next review date = now + 1 minute
        expect(result.nextReviewDate, baseTime.add(const Duration(minutes: 1)));
      });

      test('rounds fractional intervals correctly', () {
        // Given: Calculation resulting in fractional interval (rep≥2 applies ease factor)
        final result = service.calculateNextReview(
          currentIntervalMinutes: 1440,
          currentEaseFactor: 1.5,
          currentRepetitions: 2,
          rating: Rating.good,
          now: baseTime,
        );

        // Then: 1440 × 1.5 = 2160 minutes (1.5 days)
        expect(result.nextIntervalMinutes, 2160);
      });
    });

    group('Real-world Scenarios', () {
      test('tracks progression through Anki-style learning phase', () {
        var currentInterval = 0;
        var currentEaseFactor = 2.5;
        var currentRepetitions = 0;
        var currentTime = baseTime;

        // Review 1: Good → 1 day (1440 minutes), rep=0→1
        var result = service.calculateNextReview(
          currentIntervalMinutes: currentInterval,
          currentEaseFactor: currentEaseFactor,
          currentRepetitions: currentRepetitions,
          rating: Rating.good,
          now: currentTime,
        );
        expect(result.nextIntervalMinutes, 1440);
        expect(result.nextRepetitions, 1);

        // Review 2: Good → 3 days (4320 minutes), rep=1→2
        result = service.calculateNextReview(
          currentIntervalMinutes: result.nextIntervalMinutes,
          currentEaseFactor: result.nextEaseFactor,
          currentRepetitions: result.nextRepetitions,
          rating: Rating.good,
          now: currentTime.add(Duration(minutes: result.nextIntervalMinutes)),
        );
        expect(result.nextIntervalMinutes, 4320);
        expect(result.nextRepetitions, 2);

        // Review 3: Good → 3d × 2.5 = 7.5d (10800 minutes), rep=2→3
        result = service.calculateNextReview(
          currentIntervalMinutes: result.nextIntervalMinutes,
          currentEaseFactor: result.nextEaseFactor,
          currentRepetitions: result.nextRepetitions,
          rating: Rating.good,
          now: currentTime.add(Duration(minutes: result.nextIntervalMinutes)),
        );
        expect(result.nextIntervalMinutes, 10800);
        expect(result.nextRepetitions, 3);

        // Review 4: Good → 7.5d × 2.5 = 18.75d (27000 minutes), rep=3→4
        result = service.calculateNextReview(
          currentIntervalMinutes: result.nextIntervalMinutes,
          currentEaseFactor: result.nextEaseFactor,
          currentRepetitions: result.nextRepetitions,
          rating: Rating.good,
          now: currentTime.add(Duration(minutes: result.nextIntervalMinutes)),
        );
        expect(result.nextIntervalMinutes, 27000);
        expect(result.nextRepetitions, 4);
      });

      test('handles ease factor degradation with multiple hard reviews', () {
        var easeFactor = 2.5;

        // Three hard reviews in a row
        for (var i = 0; i < 3; i++) {
          final result = service.calculateNextReview(
            currentIntervalMinutes: 14400,
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
            currentIntervalMinutes: 14400,
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
      test('Given 0 minutes, When formatting, Then returns "<1m"', () {
        final result = SrsService.formatInterval(0);
        expect(result, '<1m');
      });

      test('Given 1 minute, When formatting, Then returns "1m"', () {
        final result = SrsService.formatInterval(1);
        expect(result, '1m');
      });

      test('Given 10 minutes, When formatting, Then returns "10m"', () {
        final result = SrsService.formatInterval(10);
        expect(result, '10m');
      });

      test('Given 60 minutes, When formatting, Then returns "1h"', () {
        final result = SrsService.formatInterval(60);
        expect(result, '1h');
      });

      test('Given 1440 minutes (1 day), When formatting, Then returns "1d"', () {
        final result = SrsService.formatInterval(1440);
        expect(result, '1d');
      });

      test('Given 4320 minutes (3 days), When formatting, Then returns "3d"', () {
        final result = SrsService.formatInterval(4320);
        expect(result, '3d');
      });

      test('Given 8640 minutes (6 days), When formatting, Then returns "6d"', () {
        final result = SrsService.formatInterval(8640);
        expect(result, '6d');
      });

      test('Given 10080 minutes (7 days), When formatting, Then returns "1w"', () {
        final result = SrsService.formatInterval(10080);
        expect(result, '1w');
      });

      test('Given 20160 minutes (14 days), When formatting, Then returns "2w"', () {
        final result = SrsService.formatInterval(20160);
        expect(result, '2w');
      });

      test('Given 30240 minutes (21 days), When formatting, Then returns "3w"', () {
        final result = SrsService.formatInterval(30240);
        expect(result, '3w');
      });

      test('Given 40320 minutes (28 days), When formatting, Then returns "4w"', () {
        final result = SrsService.formatInterval(40320);
        expect(result, '4w');
      });

      test('Given 43200 minutes (30 days), When formatting, Then returns "1mo"', () {
        final result = SrsService.formatInterval(43200);
        expect(result, '1mo');
      });

      test('Given 86400 minutes (60 days), When formatting, Then returns "2mo"', () {
        final result = SrsService.formatInterval(86400);
        expect(result, '2mo');
      });

      test('Given 129600 minutes (90 days), When formatting, Then returns "3mo"', () {
        final result = SrsService.formatInterval(129600);
        expect(result, '3mo');
      });

      test('Given 259200 minutes (180 days), When formatting, Then returns "6mo"', () {
        final result = SrsService.formatInterval(259200);
        expect(result, '6mo');
      });

      test('Given 524160 minutes (364 days), When formatting, Then returns "12mo"', () {
        final result = SrsService.formatInterval(524160);
        expect(result, '12mo');
      });

      test('Given 525600 minutes (365 days), When formatting, Then returns absolute date', () {
        final referenceDate = DateTime(2025, 1, 1);
        final result = SrsService.formatInterval(525600, referenceDate: referenceDate);
        
        // Expected: Jan 1, 2025 + 365 days = Jan 1, 2026
        expect(result, 'Jan 1, 2026');
      });

      test('Given 576000 minutes (400 days), When formatting, Then returns absolute date', () {
        final referenceDate = DateTime(2025, 1, 15);
        final result = SrsService.formatInterval(576000, referenceDate: referenceDate);
        
        // Expected: Jan 15, 2025 + 400 days = Feb 19, 2026
        expect(result, 'Feb 19, 2026');
      });

      test('Given 1051200 minutes (730 days), When formatting, Then returns absolute date 2 years later', () {
        final referenceDate = DateTime(2025, 3, 1);
        final result = SrsService.formatInterval(1051200, referenceDate: referenceDate);
        
        // Expected: Mar 1, 2025 + 730 days = Mar 1, 2027
        expect(result, 'Mar 1, 2027');
      });

      test('Given no reference date for large interval, When formatting, Then uses DateTime.now()', () {
        // This test just verifies it doesn't crash
        final result = SrsService.formatInterval(720000); // 500 days
        
        // Result should be a date string (format: "Mon DD, YYYY")
        expect(result, matches(r'\w{3} \d{1,2}, \d{4}'));
      });

      test('Given boundary cases, When formatting, Then handles correctly', () {
        expect(SrsService.formatInterval(0), '<1m');
        expect(SrsService.formatInterval(8640), '6d'); // Last day before weeks
        expect(SrsService.formatInterval(10080), '1w'); // First week
        expect(SrsService.formatInterval(41760), '4w'); // Last week before months
        expect(SrsService.formatInterval(43200), '1mo'); // First month
        expect(SrsService.formatInterval(524160), '12mo'); // Last month before absolute
        
        final ref = DateTime(2025, 1, 1);
        final result365 = SrsService.formatInterval(525600, referenceDate: ref);
        expect(result365, 'Jan 1, 2026'); // First absolute date
      });
    });
  });
}
