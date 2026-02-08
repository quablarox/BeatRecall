/// Application settings model.
/// 
/// Related requirements:
/// - SETTINGS-001: Daily new cards limit
/// - SETTINGS-002: Audio-only mode
/// - SETTINGS-003: General preferences
class AppSettings {
  /// Maximum number of new cards to study per day.
  /// Default: 20 cards/day
  /// Range: 0-999
  final int newCardsPerDay;

  /// Enable audio-only mode (collapse video player).
  /// Default: false (video visible)
  final bool audioOnlyMode;

  /// Theme mode: 'light', 'dark', or 'system'
  /// Default: 'system'
  final String themeMode;

  /// Auto-play video when card appears.
  /// Default: true
  final bool autoPlayVideo;

  const AppSettings({
    this.newCardsPerDay = 20,
    this.audioOnlyMode = false,
    this.themeMode = 'system',
    this.autoPlayVideo = true,
  });

  /// Create settings from map (for persistence)
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      newCardsPerDay: map['newCardsPerDay'] as int? ?? 20,
      audioOnlyMode: map['audioOnlyMode'] as bool? ?? false,
      themeMode: map['themeMode'] as String? ?? 'system',
      autoPlayVideo: map['autoPlayVideo'] as bool? ?? true,
    );
  }

  /// Convert settings to map (for persistence)
  Map<String, dynamic> toMap() {
    return {
      'newCardsPerDay': newCardsPerDay,
      'audioOnlyMode': audioOnlyMode,
      'themeMode': themeMode,
      'autoPlayVideo': autoPlayVideo,
    };
  }

  /// Create copy with modifications
  AppSettings copyWith({
    int? newCardsPerDay,
    bool? audioOnlyMode,
    String? themeMode,
    bool? autoPlayVideo,
  }) {
    return AppSettings(
      newCardsPerDay: newCardsPerDay ?? this.newCardsPerDay,
      audioOnlyMode: audioOnlyMode ?? this.audioOnlyMode,
      themeMode: themeMode ?? this.themeMode,
      autoPlayVideo: autoPlayVideo ?? this.autoPlayVideo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.newCardsPerDay == newCardsPerDay &&
        other.audioOnlyMode == audioOnlyMode &&
        other.themeMode == themeMode &&
        other.autoPlayVideo == autoPlayVideo;
  }

  @override
  int get hashCode {
    return Object.hash(
      newCardsPerDay,
      audioOnlyMode,
      themeMode,
      autoPlayVideo,
    );
  }

  @override
  String toString() {
    return 'AppSettings(newCardsPerDay: $newCardsPerDay, audioOnlyMode: $audioOnlyMode, themeMode: $themeMode, autoPlayVideo: $autoPlayVideo)';
  }
}
