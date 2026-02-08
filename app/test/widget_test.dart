// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beat_recall/presentation/app/beat_recall_app.dart';

void main() {
  testWidgets('App widget can be created', (WidgetTester tester) async {
    // This is a smoke test to ensure the app widget can be instantiated
    await tester.pumpWidget(const BeatRecallApp());
    
    // Initial frame should show loading indicator while database initializes
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
