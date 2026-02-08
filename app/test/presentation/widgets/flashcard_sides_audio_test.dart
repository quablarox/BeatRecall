import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_recall/presentation/widgets/flashcard_sides.dart';
import 'package:beat_recall/services/settings_service.dart';

/// Test suite for FlashcardFront widget with audio-only mode
/// 
/// **Features Tested:**
/// - @SETTINGS-002: Audio-only mode integration
/// 
/// Note: Full YouTube player tests are skipped because they require platform initialization
/// that is complex to set up in unit tests. Audio-only mode display logic is tested here.
void main() {
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsService = SettingsService();
    await settingsService.initialize();
  });

  Widget createTestWidget({bool audioOnlyMode = false}) {
    if (audioOnlyMode) {
      settingsService.setAudioOnlyMode(true);
    }
    
    return ChangeNotifierProvider<SettingsService>.value(
      value: settingsService,
      child: MaterialApp(
        home: Scaffold(
          body: FlashcardFront(
            youtubeId: 'dQw4w9WgXcQ',
            startAtSecond: 30,
            onShowAnswer: () {},
          ),
        ),
      ),
    );
  }

  group('@SETTINGS-002 Audio-Only Mode Integration', () {
    testWidgets('Given audio-only mode enabled, When displaying card, Then shows audio bar', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      // Should show the audio-only bar
      expect(find.text('Audio-Only Mode'), findsOneWidget);
      expect(find.text('Audio is playing in the background'), findsOneWidget);
      expect(find.byIcon(Icons.audiotrack), findsOneWidget);
    });

    testWidgets('Given audio-only mode enabled, When displayed, Then still shows show answer button', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      // Should show audio bar instead of video player
      expect(find.text('Audio-Only Mode'), findsOneWidget);
      
      // Should still show the "Show Answer" button
      expect(find.text('Show Answer'), findsOneWidget);
    });

    testWidgets('Given audio-only mode, When toggled, Then updates display dynamically', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: false));
      await tester.pump();
      
      // Initially no audio bar (video player will try to render but may fail in tests)
      expect(find.text('Audio-Only Mode'), findsNothing);
      
      // Enable audio-only mode
      await settingsService.setAudioOnlyMode(true);
      await tester.pumpAndSettle();
      
      // Now should show audio bar
      expect(find.text('Audio-Only Mode'), findsOneWidget);
    });

    testWidgets('Given audio-only bar, When displayed, Then shows settings hint', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      // Should show settings icon with tooltip
      final settingsIconFinder = find.byIcon(Icons.settings);
      expect(settingsIconFinder, findsOneWidget);
      
      // Verify tooltip
      final tooltip = find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'Change in Settings',
      );
      expect(tooltip, findsOneWidget);
    });
  });

  group('FlashcardFront Basic Rendering', () {
    testWidgets('Given flashcard front, When displayed, Then shows show answer button', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      expect(find.text('Show Answer'), findsOneWidget);
      expect(find.text('Listen and try to recall...'), findsOneWidget);
    });

    testWidgets('Given flashcard front, When displayed, Then shows keyboard hint', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      expect(find.text('Or press Space to flip'), findsOneWidget);
    });

    testWidgets('Given flashcard front, When created, Then renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      // Should render successfully
      expect(find.byType(FlashcardFront), findsOneWidget);
    });

    testWidgets('Given audio-only mode, When rendering, Then maintains proper layout', (tester) async {
      await tester.pumpWidget(createTestWidget(audioOnlyMode: true));
      await tester.pumpAndSettle();
      
      // Verify all key elements are present
      expect(find.text('Audio-Only Mode'), findsOneWidget);
      expect(find.text('Show Answer'), findsOneWidget);
      expect(find.text('Listen and try to recall...'), findsOneWidget);
      expect(find.byIcon(Icons.audiotrack), findsOneWidget);
    });
  });
}
