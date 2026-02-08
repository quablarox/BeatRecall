import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../entities/isar_flashcard.dart';

/// Singleton manager for the Isar database instance.
///
/// Provides centralized access to the database and ensures
/// proper initialization before use.
class IsarDatabase {
  IsarDatabase._();

  static Isar? _instance;

  /// Gets the current Isar instance.
  ///
  /// Throws [StateError] if the database has not been opened yet.
  /// Call [IsarDatabase.open()] first.
  static Isar get instance {
    final isar = _instance;
    if (isar == null) {
      throw StateError('IsarDatabase not opened. Call IsarDatabase.open() first.');
    }
    return isar;
  }

  /// Opens the Isar database with the application schema.
  ///
  /// Safe to call multiple times - returns existing instance if already open.
  /// Throws [UnsupportedError] on web platforms.
  static Future<Isar> open() async {
    if (_instance != null) return _instance!;

    if (kIsWeb) {
      throw UnsupportedError('Isar is not supported on web in this project.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [IsarFlashcardSchema],
      directory: dir.path,
      name: 'beat_recall',
    );

    _instance = isar;
    return isar;
  }

  /// Closes the database instance.
  ///
  /// Call this when the app is shutting down.
  static Future<void> close() async {
    final isar = _instance;
    _instance = null;
    if (isar != null) {
      await isar.close();
    }
  }
}
