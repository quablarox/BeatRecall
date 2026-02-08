import 'package:isar/isar.dart';

part 'flashcard.g.dart';

@collection
class Flashcard {
  Id id = Isar.autoIncrement;

  late String youtubeId;
  late String title;
  late String artist;
  String? album;

  // SRS fields
  int intervalDays = 0;
  double easeFactor = 2.5;
  int repetitions = 0;
  DateTime nextReviewDate = DateTime.now();

  // Playback configuration
  int startAtSecond = 0;
  int? endAtSecond;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
