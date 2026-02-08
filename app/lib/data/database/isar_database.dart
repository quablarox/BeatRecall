import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/flashcard.dart';

class IsarDatabase {
  IsarDatabase._();

  static Isar? _instance;

  static Isar get instance {
    final isar = _instance;
    if (isar == null) {
      throw StateError('IsarDatabase not opened. Call IsarDatabase.open() first.');
    }
    return isar;
  }

  static Future<Isar> open() async {
    if (_instance != null) return _instance!;

    if (kIsWeb) {
      throw UnsupportedError('Isar is not supported on web in this project.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [FlashcardSchema],
      directory: dir.path,
      name: 'beat_recall',
    );

    _instance = isar;
    return isar;
  }

  static Future<void> close() async {
    final isar = _instance;
    _instance = null;
    if (isar != null) {
      await isar.close();
    }
  }
}
