/// Utility for extracting YouTube video IDs from various URL formats.
///
/// Supports:
/// - https://www.youtube.com/watch?v=VIDEO_ID
/// - https://youtu.be/VIDEO_ID 
/// - https://m.youtube.com/watch?v=VIDEO_ID
/// - VIDEO_ID (direct ID)
class YouTubeIdExtractor {
  /// Regular expression patterns for YouTube URLs
  static final RegExp _fullUrlPattern = RegExp(
    r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
  );

  /// Pattern for direct video ID (11 characters)
  static final RegExp _directIdPattern = RegExp(
    r'^[a-zA-Z0-9_-]{11}$',
  );

  /// Extracts YouTube video ID from various input formats.
  ///
  /// Returns null if the input is not a valid YouTube URL or ID.
  /// 
  /// Examples:
  /// ```dart
  /// extract('https://www.youtube.com/watch?v=dQw4w9WgXcQ') // 'dQw4w9WgXcQ'
  /// extract('https://youtu.be/dQw4w9WgXcQ')                 // 'dQw4w9WgXcQ'
  /// extract('dQw4w9WgXcQ')                                   // 'dQw4w9WgXcQ'
  /// extract('invalid')                                       // null
  /// ```
  static String? extract(String input) {
    if (input.isEmpty) return null;

    final trimmed = input.trim();

    // Try full URL patterns first
    final urlMatch = _fullUrlPattern.firstMatch(trimmed);
    if (urlMatch != null && urlMatch.groupCount >= 1) {
      return urlMatch.group(1);
    }

    // Try direct ID pattern
    if (_directIdPattern.hasMatch(trimmed)) {
      return trimmed;
    }

    return null;
  }

  /// Validates if a string is a valid YouTube URL or video ID.
  static bool isValid(String input) {
    return extract(input) != null;
  }
}
