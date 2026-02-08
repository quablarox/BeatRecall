import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_recall/presentation/screens/settings/settings_screen.dart';
import 'package:beat_recall/services/settings_service.dart';

/// Test suite for SettingsScreen widget
/// 
/// **Features Tested:**
/// - @SETTINGS-001: Daily new cards limit UI
/// - @SETTINGS-002: Audio-only mode toggle
/// - @SETTINGS-003: General preferences (theme, auto-play)
void main() {
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsService = SettingsService();
    await settingsService.initialize();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<SettingsService>.value(
      value: settingsService,
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('@SETTINGS-001 Daily New Cards Limit UI', () {
    testWidgets('Given settings screen, When displayed, Then shows new cards per day', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find the new cards per day tile
      expect(find.text('New Cards Per Day'), findsOneWidget);
      expect(find.textContaining('20 cards'), findsOneWidget); // "Current: 20 cards"
    });

    testWidgets('Given new cards tile, When tapped, Then shows edit dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Tap the new cards per day tile
      await tester.tap(find.text('New Cards Per Day'));
      await tester.pumpAndSettle();
      
      // Dialog should appear
      expect(find.text('New Cards Per Day'), findsNWidgets(2)); // Title + dialog title
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Given edit dialog, When entering valid value, Then updates setting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Open dialog
      await tester.tap(find.text('New Cards Per Day'));
      await tester.pumpAndSettle();
      
      // Enter new value
      await tester.enterText(find.byType(TextField), '50');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Value should be updated
      expect(settingsService.settings.newCardsPerDay, 50);
      expect(find.textContaining('50 cards'), findsOneWidget);
    });

    testWidgets('Given edit dialog, When canceling, Then does not update', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Open dialog
      await tester.tap(find.text('New Cards Per Day'));
      await tester.pumpAndSettle();
      
      // Enter value but cancel
      await tester.enterText(find.byType(TextField), '100');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Value should not change
      expect(settingsService.settings.newCardsPerDay, 20);
    });

    testWidgets('Given settings screen, When showing remaining cards, Then displays correctly', (tester) async {
      // Study 5 cards
      for (var i = 0; i < 5; i++) {
        settingsService.incrementNewCardsStudied();
      }
      
      await tester.pumpWidget(createTestWidget());
      
      // Should show "15 cards remaining"
      expect(find.textContaining('15 cards remaining'), findsOneWidget);
    });
  });

  group('@SETTINGS-002 Audio-Only Mode Toggle', () {
    testWidgets('Given settings screen, When displayed, Then shows audio-only mode switch', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find the audio-only mode tile
      expect(find.text('Audio-Only Mode'), findsOneWidget);
      expect(find.text('Hide video player, save bandwidth'), findsOneWidget);
    });

    testWidgets('Given audio-only mode off, When toggled, Then enables setting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find and tap the switch
      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Audio-Only Mode'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );
      
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      
      // Setting should be enabled
      expect(settingsService.settings.audioOnlyMode, true);
    });

    testWidgets('Given audio-only mode on, When toggled, Then disables setting', (tester) async {
      await settingsService.setAudioOnlyMode(true);
      
      await tester.pumpWidget(createTestWidget());
      
      // Find and tap the switch
      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Audio-Only Mode'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );
      
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      
      // Setting should be disabled
      expect(settingsService.settings.audioOnlyMode, false);
    });
  });

  group('@SETTINGS-003 General Preferences', () {
    testWidgets('Given settings screen, When displayed, Then shows theme setting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find theme tile
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget); // Default
    });

    testWidgets('Given theme tile, When tapped, Then shows theme dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Tap theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      // Dialog should show all options
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System default'), findsAtLeastNWidgets(1));
    });

    testWidgets('Given theme dialog, When selecting dark, Then updates theme', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Open dialog
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      // Find the dark theme radio tile
      final darkRadio = find.ancestor(
        of: find.text('Dark'),
        matching: find.byType(RadioListTile<String>),
      );
      
      // Tap dark theme radio (this will close dialog automatically)
      await tester.tap(darkRadio);
      await tester.pumpAndSettle();
      
      // Theme should be updated
      expect(settingsService.settings.themeMode, 'dark');
    });

    testWidgets('Given theme dialog, When canceling, Then does not update', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Open dialog
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      // Dismiss dialog by tapping outside (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      
      // Theme should not change
      expect(settingsService.settings.themeMode, 'system');
    });

    testWidgets('Given settings screen, When displayed, Then shows auto-play toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find auto-play tile
      expect(find.text('Auto-Play Videos'), findsOneWidget);
    });

    testWidgets('Given auto-play on, When toggled, Then disables setting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find and tap the switch
      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Auto-Play Videos'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );
      
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      
      // Setting should be disabled
      expect(settingsService.settings.autoPlayVideo, false);
    });
  });

  group('Settings Screen UI Structure', () {
    testWidgets('Given settings screen, When displayed, Then shows all sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Verify all sections are present
      expect(find.text('Settings'), findsOneWidget); // AppBar title
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('Given settings screen, When displayed, Then shows version info', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Scroll to bottom to see version info
      await tester.scrollUntilVisible(find.text('About'), 500);
      await tester.pumpAndSettle();
      
      // Verify about section
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.0.0+1'), findsOneWidget);
      expect(find.text('Open Source'), findsOneWidget);
    });

    testWidgets('Given settings screen, When scrolling, Then all content is accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Verify top content
      expect(find.text('Learning'), findsOneWidget);
      
      // Scroll to bottom
      await tester.scrollUntilVisible(find.text('About'), 500);
      await tester.pumpAndSettle();
      
      // Verify bottom content
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Open Source'), findsOneWidget);
    });
  });
}
