import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/value_objects/app_settings.dart';

/// Service for managing application settings persistence.
/// 
/// Related requirements:
/// - SETTINGS-001: Daily new cards limit
/// - SETTINGS-002: Audio-only mode
/// - SETTINGS-003: General preferences
class SettingsService extends ChangeNotifier {
  static const String _keyNewCardsPerDay = 'settings_new_cards_per_day';
  static const String _keyAudioOnlyMode = 'settings_audio_only_mode';
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyAutoPlayVideo = 'settings_auto_play_video';
  static const String _keyNewCardsStudiedToday = 'new_cards_studied_today';
  static const String _keyLastResetDate = 'last_reset_date';

  SharedPreferences? _prefs;
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  /// Initialize settings service and load persisted settings
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _checkAndResetDailyCount();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    _settings = AppSettings(
      newCardsPerDay: _prefs!.getInt(_keyNewCardsPerDay) ?? 20,
      audioOnlyMode: _prefs!.getBool(_keyAudioOnlyMode) ?? false,
      themeMode: _prefs!.getString(_keyThemeMode) ?? 'system',
      autoPlayVideo: _prefs!.getBool(_keyAutoPlayVideo) ?? true,
    );
    notifyListeners();
  }

  /// Update new cards per day limit
  Future<void> setNewCardsPerDay(int value) async {
    if (value < 0 || value > 999) {
      throw ArgumentError('New cards per day must be between 0 and 999');
    }
    
    await _prefs?.setInt(_keyNewCardsPerDay, value);
    _settings = _settings.copyWith(newCardsPerDay: value);
    notifyListeners();
  }

  /// Update audio-only mode
  Future<void> setAudioOnlyMode(bool value) async {
    await _prefs?.setBool(_keyAudioOnlyMode, value);
    _settings = _settings.copyWith(audioOnlyMode: value);
    notifyListeners();
  }

  /// Update theme mode
  Future<void> setThemeMode(String value) async {
    if (!['light', 'dark', 'system'].contains(value)) {
      throw ArgumentError('Theme mode must be light, dark, or system');
    }
    
    await _prefs?.setString(_keyThemeMode, value);
    _settings = _settings.copyWith(themeMode: value);
    notifyListeners();
  }

  /// Update auto-play video setting
  Future<void> setAutoPlayVideo(bool value) async {
    await _prefs?.setBool(_keyAutoPlayVideo, value);
    _settings = _settings.copyWith(autoPlayVideo: value);
    notifyListeners();
  }

  /// Get count of new cards studied today
  int getNewCardsStudiedToday() {
    return _prefs?.getInt(_keyNewCardsStudiedToday) ?? 0;
  }

  /// Increment count of new cards studied today
  Future<void> incrementNewCardsStudied() async {
    final current = getNewCardsStudiedToday();
    await _prefs?.setInt(_keyNewCardsStudiedToday, current + 1);
    notifyListeners();
  }

  /// Get remaining new cards for today
  int getRemainingNewCardsToday() {
    final studied = getNewCardsStudiedToday();
    final limit = _settings.newCardsPerDay;
    return (limit - studied).clamp(0, limit);
  }

  /// Check if daily count needs to be reset (called at midnight)
  Future<void> _checkAndResetDailyCount() async {
    final lastResetDateStr = _prefs?.getString(_keyLastResetDate);
    final today = _getTodayDateString();

    if (lastResetDateStr != today) {
      // Reset daily count
      await _prefs?.setInt(_keyNewCardsStudiedToday, 0);
      await _prefs?.setString(_keyLastResetDate, today);
      notifyListeners();
    }
  }

  /// Reset daily new cards count (for testing)
  Future<void> resetDailyCount() async {
    await _prefs?.setInt(_keyNewCardsStudiedToday, 0);
    await _prefs?.setString(_keyLastResetDate, _getTodayDateString());
    notifyListeners();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
