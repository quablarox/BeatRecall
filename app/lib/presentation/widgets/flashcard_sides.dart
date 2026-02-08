import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as iframe;
import 'flashcard_widget.dart';

/// Front side of a flashcard that displays a YouTube player.
/// 
/// **Feature:** @FLASHSYS-002 (YouTube Media Player)
class FlashcardFront extends StatefulWidget {
  final String youtubeId;
  final int startAtSecond;
  final VoidCallback onShowAnswer;

  const FlashcardFront({
    super.key,
    required this.youtubeId,
    required this.startAtSecond,
    required this.onShowAnswer,
  });

  @override
  State<FlashcardFront> createState() => _FlashcardFrontState();
}

class _FlashcardFrontState extends State<FlashcardFront> {
  YoutubePlayerController? _controller;
  iframe.YoutubePlayerController? _iframeController;
  bool _hasError = false;
  String? _errorMessage;

  bool get _useIframePlayer => defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    if (_useIframePlayer) {
      _initializeIframePlayer();
    } else {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardFront oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeId != widget.youtubeId ||
        oldWidget.startAtSecond != widget.startAtSecond) {
      if (!mounted) return;
      
      _hasError = false;
      _errorMessage = null;

      // Dispose old controllers and reinitialize with new video
      if (_useIframePlayer) {
        _iframeController?.close();
        _iframeController = null;
        _initializeIframePlayer();
      } else {
        _controller?.dispose();
        _controller = null;
        _initializePlayer();
      }
    }
  }

  void _initializePlayer() {
    try {
      _controller = YoutubePlayerController(
        initialVideoId: widget.youtubeId,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          startAt: widget.startAtSecond,
          mute: false,
          enableCaption: false,
        ),
      );

      _controller!.addListener(() {
        if (!mounted) return;
        if (_controller?.value.hasError ?? false) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video unavailable';
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video';
      });
    }
  }

  void _initializeIframePlayer() {
    try {
      _iframeController = iframe.YoutubePlayerController.fromVideoId(
        videoId: widget.youtubeId,
        autoPlay: true,
        params: const iframe.YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
      
      // Seek to start position after initialization
      if (widget.startAtSecond > 0) {
        _iframeController?.seekTo(seconds: widget.startAtSecond.toDouble());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _iframeController?.close();
    super.dispose();
  }

  void _retry() {
    if (!mounted) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    if (_useIframePlayer) {
      _initializeIframePlayer();
    } else {
      _initializePlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlashcardSide(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // YouTube Player or Error State
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _hasError
                ? _buildErrorState(context)
                : _useIframePlayer
                    ? _buildIframePlayer(context)
                    : YoutubePlayer(
                        controller: _controller!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Theme.of(context).primaryColor,
                      ),
          ),
          
          // Show Answer Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Listen and try to recall...',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onShowAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Show Answer'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Or press Space to flip',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Video unavailable',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your internet connection',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIframePlayer(BuildContext context) {
    if (_iframeController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return iframe.YoutubePlayer(
      controller: _iframeController!,
      aspectRatio: 16 / 9,
    );
  }
}

/// Back side of a flashcard that displays the answer and rating buttons.
/// 
/// **Features:**
/// - @FLASHSYS-001 (Display title and artist)
/// - @FLASHSYS-003 (Answer Rating)
class FlashcardBack extends StatelessWidget {
  final String title;
  final String artist;
  final Function(int rating) onRate;
  final Map<int, String> nextIntervals;

  const FlashcardBack({
    super.key,
    required this.title,
    required this.artist,
    required this.onRate,
    required this.nextIntervals,
  });

  @override
  Widget build(BuildContext context) {
    return FlashcardSide(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Answer Section
            const Text(
              'Answer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              artist,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Rating Buttons Section
            const Text(
              'How well did you recall?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Rating Buttons
            _buildRatingButtons(context),
            
            const SizedBox(height: 16),
            Text(
              'Press 1-4 for keyboard shortcuts',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: 'Again',
                subtitle: nextIntervals[0] ?? 'Soon',
rating: 0,
                color: const Color(0xFFF44336), // Red
                onPressed: () => onRate(0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: 'Hard',
                subtitle: nextIntervals[1] ?? '1d',
                rating: 1,
                color: const Color(0xFFFF9800), // Orange
                onPressed: () => onRate(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: 'Good',
                subtitle: nextIntervals[3] ?? '3d',
                rating: 3,
                color: const Color(0xFF4CAF50), // Green
                onPressed: () => onRate(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: 'Easy',
                subtitle: nextIntervals[4] ?? '7d',
                rating: 4,
                color: const Color(0xFF2196F3), // Blue
                onPressed: () => onRate(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final int rating;
  final Color color;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.rating,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        minimumSize: const Size(120, 72), // Touch-friendly size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
