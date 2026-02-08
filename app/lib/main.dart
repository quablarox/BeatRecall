import 'package:flutter/material.dart';

import 'data/database/isar_database.dart';
import 'presentation/app/beat_recall_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDatabase.open();
  runApp(const BeatRecallApp());
}

