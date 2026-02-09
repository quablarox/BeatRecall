import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:beat_recall/domain/entities/flashcard.dart';
import 'package:beat_recall/domain/repositories/card_repository.dart';
import 'package:beat_recall/presentation/screens/card_edit/edit_card_screen.dart';

class MockCardRepository implements CardRepository {
  final List<Flashcard> savedCards = [];
  final List<String> deletedUuids = [];

  @override
  Future<void> save(Flashcard card) async {
    savedCards.add(card);
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    deletedUuids.add(uuid);
  }

  @override
  Future<List<Flashcard>> fetchDueCards({int limit = 100}) async => [];

  @override
  Future<Flashcard?> findByUuid(String uuid) async => null;

  @override
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async => [];

  @override
  Future<int> countAllCards() async => 0;

  @override
  Future<int> countDueCards() async => 0;

  @override
  Future<void> saveAll(List<Flashcard> cards) async {}

  @override
  Future<bool> existsByYoutubeId(String youtubeId) async => false;

  @override
  Future<Flashcard?> findByYoutubeId(String youtubeId) async => null;

  @override
  Future<void> updateSrsFields({
    required String cardUuid,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
  }) async {}

  @override
  Future<void> resetAllProgress() async {}
}

void main() {
  late MockCardRepository repository;
  late Flashcard card;

  setUp(() {
    repository = MockCardRepository();
    final now = DateTime(2026, 2, 9);
    card = Flashcard(
      uuid: 'card-uuid-1',
      youtubeId: 'YOUTUBE123',
      title: 'Original Title',
      artist: 'Original Artist',
      album: 'Original Album',
      intervalDays: 5,
      easeFactor: 2.5,
      repetitions: 2,
      nextReviewDate: now,
      startAtSecond: 10,
      endAtSecond: 30,
      createdAt: now,
      updatedAt: now,
    );
  });

  Widget createTestWidget() {
    return Provider<CardRepository>.value(
      value: repository,
      child: MaterialApp(
        home: EditCardScreen(card: card),
      ),
    );
  }

  group('EditCardScreen (@CARDMGMT-003)', () {
    testWidgets('loads existing card values', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final titleField = tester.widget<TextFormField>(
        find.byKey(const Key('edit-card-title')),
      );
      final artistField = tester.widget<TextFormField>(
        find.byKey(const Key('edit-card-artist')),
      );
      final youtubeField = tester.widget<TextFormField>(
        find.byKey(const Key('edit-card-youtube-id')),
      );
      final albumField = tester.widget<TextFormField>(
        find.byKey(const Key('edit-card-album')),
      );
      final startAtField = tester.widget<TextFormField>(
        find.byKey(const Key('edit-card-start-at')),
      );
      final endAtField = tester.widget<TextFormField>(
        find.byKey(const Key('edit-card-end-at')),
      );

      expect(titleField.controller!.text, 'Original Title');
      expect(artistField.controller!.text, 'Original Artist');
      expect(youtubeField.controller!.text, 'YOUTUBE123');
      expect(albumField.controller!.text, 'Original Album');
      expect(startAtField.controller!.text, '10');
      expect(endAtField.controller!.text, '30');
    });

    testWidgets('saves updated values to repository', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byKey(const Key('edit-card-title')),
        'Updated Title',
      );
      await tester.enterText(
        find.byKey(const Key('edit-card-artist')),
        'Updated Artist',
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(repository.savedCards.length, 1);
      expect(repository.savedCards.first.title, 'Updated Title');
      expect(repository.savedCards.first.artist, 'Updated Artist');
    });
  });

  group('EditCardScreen (@CARDMGMT-004)', () {
    testWidgets('deletes card after confirmation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Card'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(repository.deletedUuids, ['card-uuid-1']);
    });
  });
}
