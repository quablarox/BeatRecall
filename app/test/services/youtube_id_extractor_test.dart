import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/services/youtube_id_extractor.dart';

void main() {
  group('YouTubeIdExtractor (@CARDMGMT-001)', () {
    group('extract()', () {
      test('extracts ID from standard YouTube URL', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        final id = YouTubeIdExtractor.extract(url);
        
        expect(id, 'dQw4w9WgXcQ');
      });

      test('extracts ID from shortened youtu.be URL', () {
        const url = 'https://youtu.be/dQw4w9WgXcQ';
        final id = YouTubeIdExtractor.extract(url);
        
        expect(id, 'dQw4w9WgXcQ');
      });

      test('extracts ID from mobile URL', () {
        const url = 'https://m.youtube.com/watch?v=dQw4w9WgXcQ';
        final id = YouTubeIdExtractor.extract(url);
        
        expect(id, 'dQw4w9WgXcQ');
      });

      test('extracts ID from embed URL', () {
        const url = 'https://www.youtube.com/embed/dQw4w9WgXcQ';
        final id = YouTubeIdExtractor.extract(url);
        
        expect(id, 'dQw4w9WgXcQ');
      });

      test('extracts ID from direct video ID', () {
        const id = 'dQw4w9WgXcQ';
        final extracted = YouTubeIdExtractor.extract(id);
        
        expect(extracted, 'dQw4w9WgXcQ');
      });

      test('handles URL with additional parameters', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s';
        final id = YouTubeIdExtractor.extract(url);
        
        expect(id, 'dQw4w9WgXcQ');
      });

      test('returns null for invalid URL', () {
        const invalid = 'not-a-youtube-url';
        final id = YouTubeIdExtractor.extract(invalid);
        
        expect(id, null);
      });

      test('returns null for empty string', () {
        const empty = '';
        final id = YouTubeIdExtractor.extract(empty);
        
        expect(id, null);
      });

      test('returns null for too short ID', () {
        const short = 'abc';
        final id = YouTubeIdExtractor.extract(short);
        
        expect(id, null);
      });

      test('returns null for too long ID', () {
        const long = 'abcdefghijkl'; // 12 characters
        final id = YouTubeIdExtractor.extract(long);
        
        expect(id, null);
      });

      test('handles whitespace around input', () {
        const url = '  https://www.youtube.com/watch?v=dQw4w9WgXcQ  ';
        final id = YouTubeIdExtractor.extract(url);
        
        expect(id, 'dQw4w9WgXcQ');
      });

      test('extracts ID with underscores and hyphens', () {
        const id = 'abc-DEF_123';
        final extracted = YouTubeIdExtractor.extract(id);
        
        expect(extracted, 'abc-DEF_123');
      });
    });

    group('isValid()', () {
      test('returns true for valid YouTube URL', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        expect(YouTubeIdExtractor.isValid(url), true);
      });

      test('returns true for valid direct ID', () {
        const id = 'dQw4w9WgXcQ';
        expect(YouTubeIdExtractor.isValid(id), true);
      });

      test('returns false for invalid input', () {
        const invalid = 'not-valid';
        expect(YouTubeIdExtractor.isValid(invalid), false);
      });

      test('returns false for empty string', () {
        const empty = '';
        expect(YouTubeIdExtractor.isValid(empty), false);
      });
    });
  });
}
