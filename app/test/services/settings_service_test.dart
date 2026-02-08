import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_recall/domain/value_objects/app_settings.dart';
import 'package:beat_recall/services/settings_service.dart';

/// Test suite for SettingsService
/// 
/// **Features Tested:**
/// - @SETTINGS-001: Daily new cards limit
/// - @SETTINGS-002: Audio-only mode
/// - @SETTINGS-003: General preferences (theme, auto-play)
void main() {
  late SettingsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = SettingsService();
    await service.initialize();
  });

  group('@SETTINGS-001 Daily New Cards Limit', () {
    test('Given default settings, When initialized, Then newCardsPerDay is 20', () {
      expect(service.settings.newCardsPerDay, 20);
    });

    test('Given custom limit, When set, Then value is persisted', () async {
      await service.setNewCardsPerDay(50);
      
      expect(service.settings.newCardsPerDay, 50);
      
      // Verify persistence
      final newService = SettingsService();
      await newService.initialize();
      expect(newService.settings.newCardsPerDay, 50);
    });

    test('Given 0 cards per day, When set, Then accepts 0', () async {
      await service.setNewCardsPerDay(0);
      
      expect(service.settings.newCardsPerDay, 0);
    });

    test('Given 999 cards per day, When set, Then accepts 999', () async {
      await service.setNewCardsPerDay(999);
      
      expect(service.settings.newCardsPerDay, 999);
    });

    test('Given no cards studied today, When checked, Then returns 0', () {
      expect(service.getNewCardsStudiedToday(), 0);
    });

    test('Given cards studied, When incremented, Then count increases', () {
      service.incrementNewCardsStudied();
      expect(service.getNewCardsStudiedToday(), 1);
      
      service.incrementNewCardsStudied();
      expect(service.getNewCardsStudiedToday(), 2);
    });

    test('Given cards studied today, When getting remaining, Then calculates correctly', () {
      service.incrementNewCardsStudied();
      service.incrementNewCardsStudied();
      service.incrementNewCardsStudied();
      
      final remaining = service.getRemainingNewCardsToday();
      expect(remaining, 17); // 20 - 3 = 17
    });

    test('Given limit of 5, When 5 studied, Then remaining is 0', () async {
      await service.setNewCardsPerDay(5);
      
      for (var i = 0; i < 5; i++) {
        service.incrementNewCardsStudied();
      }
      
      expect(service.getRemainingNewCardsToday(), 0);
    });

    test('Given limit of 0, When checked, Then remaining is always 0', () async {
      await service.setNewCardsPerDay(0);
      
      expect(service.getRemainingNewCardsToday(), 0);
    });

    test('Given cards studied yesterday, When new day, Then counter resets', () async {
      // Simulate yesterday
      SharedPreferences.setMockInitialValues({
        'settings.newCardsPerDay': 20,
        'settings.audioOnlyMode': false,
        'settings.themeMode': 'system',
        'settings.autoPlayVideo': true,
        'newCardsStudiedToday': 10,
        'lastResetDate': '2024-01-01',
      });
      
      service = SettingsService();
      await service.initialize();
      
      // After initialization on a new day, counter should be reset
      expect(service.getNewCardsStudiedToday(), 0);
    });
  });

  group('@SETTINGS-002 Audio-Only Mode', () {
    test('Given default settings, When initialized, Then audioOnlyMode is false', () {
      expect(service.settings.audioOnlyMode, false);
    });

    test('Given audio-only enabled, When set, Then value is persisted', () async {
      await service.setAudioOnlyMode(true);
      
      expect(service.settings.audioOnlyMode, true);
      
      // Verify persistence
      final newService = SettingsService();
      await newService.initialize();
      expect(newService.settings.audioOnlyMode, true);
    });

    test('Given audio-only enabled, When disabled, Then value is persisted', () async {
      await service.setAudioOnlyMode(true);
      await service.setAudioOnlyMode(false);
      
      expect(service.settings.audioOnlyMode, false);
      
      // Verify persistence
      final newService = SettingsService();
      await newService.initialize();
      expect(newService.settings.audioOnlyMode, false);
    });
  });

  group('@SETTINGS-003 General Preferences', () {
    test('Given default settings, When initialized, Then themeMode is system', () {
      expect(service.settings.themeMode, 'system');
    });

    test('Given dark theme, When set, Then value is persisted', () async {
      await service.setThemeMode('dark');
      
      expect(service.settings.themeMode, 'dark');
      
      // Verify persistence
      final newService = SettingsService();
      await newService.initialize();
      expect(newService.settings.themeMode, 'dark');
    });

    test('Given light theme, When set, Then value is persisted', () async {
      await service.setThemeMode('light');
      
      expect(service.settings.themeMode, 'light');
    });

    test('Given default settings, When initialized, Then autoPlayVideo is true', () {
      expect(service.settings.autoPlayVideo, true);
    });

    test('Given auto-play disabled, When set, Then value is persisted', () async {
      await service.setAutoPlayVideo(false);
      
      expect(service.settings.autoPlayVideo, false);
      
      // Verify persistence
      final newService = SettingsService();
      await newService.initialize();
      expect(newService.settings.autoPlayVideo, false);
    });
  });

  group('AppSettings Value Object', () {
    test('Given settings map, When fromMap, Then creates correct AppSettings', () {
      final map = {
        'newCardsPerDay': 30,
        'audioOnlyMode': true,
        'themeMode': 'dark',
        'autoPlayVideo': false,
      };
      
      final settings = AppSettings.fromMap(map);
      
      expect(settings.newCardsPerDay, 30);
      expect(settings.audioOnlyMode, true);
      expect(settings.themeMode, 'dark');
      expect(settings.autoPlayVideo, false);
    });

    test('Given AppSettings, When toMap, Then creates correct map', () {
      const settings = AppSettings(
        newCardsPerDay: 15,
        audioOnlyMode: true,
        themeMode: 'light',
        autoPlayVideo: false,
      );
      
      final map = settings.toMap();
      
      expect(map['newCardsPerDay'], 15);
      expect(map['audioOnlyMode'], true);
      expect(map['themeMode'], 'light');
      expect(map['autoPlayVideo'], false);
    });

    test('Given AppSettings, When copyWith, Then creates new instance with changes', () {
      const settings = AppSettings();
      final updated = settings.copyWith(newCardsPerDay: 100);
      
      expect(updated.newCardsPerDay, 100);
      expect(updated.audioOnlyMode, false); // Unchanged
      expect(settings.newCardsPerDay, 20); // Original unchanged
    });

    test('Given AppSettings, When copyWith multiple, Then updates all specified', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        newCardsPerDay: 50,
        audioOnlyMode: true,
        themeMode: 'dark',
      );
      
      expect(updated.newCardsPerDay, 50);
      expect(updated.audioOnlyMode, true);
      expect(updated.themeMode, 'dark');
      expect(updated.autoPlayVideo, true); // Unchanged
    });
  });

  group('SettingsService Change Notification', () {
    test('Given settings service, When value changes, Then notifies listeners', () async {
      var notified = false;
      service.addListener(() {
        notified = true;
      });
      
      await service.setNewCardsPerDay(50);
      
      expect(notified, true);
    });

    test('Given multiple listeners, When value changes, Then all are notified', () async {
      var count = 0;
      service.addListener(() => count++);
      service.addListener(() => count++);
      service.addListener(() => count++);
      
      await service.setAudioOnlyMode(true);
      
      expect(count, 3);
    });
  });
}
