import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as iframe;
import '../../services/settings_service.dart';
import 'flashcard_widget.dart';

/// Front side of a flashcard that displays a YouTube player.
/// 
/// **Feature:** @FLASHSYS-002 (YouTube Media Player)
class FlashcardFront extends StatefulWidget {
  final String youtubeId;
  final int startAtSecond;
  final VoidCallback onShowAnswer;
  final bool enablePlayer;
  final Function(int newOffset)? onUpdateOffset;

  const FlashcardFront({
    super.key,
    required this.youtubeId,
    required this.startAtSecond,
    required this.onShowAnswer,
    this.enablePlayer = true,
    this.onUpdateOffset,
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
    if (!widget.enablePlayer) return;
    if (_useIframePlayer) {
      _initializeIframePlayer();
    } else {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardFront oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enablePlayer) return;
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
        if (!mounted || _controller == null) return;
        try {
          if (_controller?.value.hasError ?? false) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Video unavailable';
              });
            }
          }
        } catch (e) {
          // Controller was disposed, ignore
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
    try {
      _controller?.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      _iframeController?.close();
    } catch (e) {
      // Controller already disposed
    }
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
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        final audioOnlyMode = settingsService.settings.audioOnlyMode;
        
        return FlashcardSide(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // YouTube Player, Audio Bar, or Error State
              if (audioOnlyMode) ...[
                // Keep the player in the tree so audio continues playing
                Offstage(
                  offstage: true,
                  child: _buildPlayerWidget(context),
                ),
                _buildAudioOnlyBar(context),
              ] else
                _buildPlayerWidget(context),
              
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
                    Tooltip(
                      message: 'Reveal the answer',
                      child: SizedBox(
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
      },
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
                  Tooltip(
                    message: 'Retry loading video',
                    child: ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
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

  Widget _buildPlayerWidget(BuildContext context) {
    if (!widget.enablePlayer) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _hasError
              ? _buildErrorState(context)
              : _useIframePlayer
                  ? _buildIframePlayer(context)
                  : _controller == null
                      ? const SizedBox.shrink()
                      : YoutubePlayer(
                          controller: _controller!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Theme.of(context).primaryColor,
                        ),
        ),
        if (!_hasError && (_controller != null || _iframeController != null))
          _buildPlayerControls(context),
      ],
    );
  }

  Widget _buildPlayerControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _skipSeconds(-10),
            icon: const Icon(Icons.replay_10),
            tooltip: 'Back 10 seconds',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _skipSeconds(10),
            icon: const Icon(Icons.forward_10),
            tooltip: 'Forward 10 seconds',
          ),
          const SizedBox(width: 16),
          if (widget.onUpdateOffset != null)
            Tooltip(
              message: 'Use current position as start time',
              child: OutlinedButton.icon(
                onPressed: _setCurrentTimeAsOffset,
                icon: const Icon(Icons.bookmark_add, size: 18),
                label: const Text('Set Start'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _skipSeconds(int seconds) async {
    if (_useIframePlayer && _iframeController != null) {
      final currentTime = await _iframeController!.currentTime;
      _iframeController!.seekTo(
        seconds: (currentTime ?? 0) + seconds.toDouble(),
      );
    } else if (_controller != null) {
      final currentPos = _controller!.value.position.inSeconds;
      _controller!.seekTo(Duration(seconds: currentPos + seconds));
    }
  }

  void _setCurrentTimeAsOffset() async {
    if (widget.onUpdateOffset == null) return;

    int currentSeconds = 0;
    if (_useIframePlayer && _iframeController != null) {
      final currentTime = await _iframeController!.currentTime;
      currentSeconds = (currentTime ?? 0).round();
    } else if (_controller != null) {
      currentSeconds = _controller!.value.position.inSeconds;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Start Time'),
        content: Text(
          'Set start time to $currentSeconds seconds?\n\nThis will update the card to always start at this position.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onUpdateOffset!(currentSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start time set to $currentSeconds seconds')),
      );
    }
  }

  /// Builds a compact audio-only bar when video is hidden.
  /// 
  /// **Feature:** @SETTINGS-002 (Audio-only mode)
  Widget _buildAudioOnlyBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.audiotrack,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio-Only Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Audio is playing in the background',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Change in Settings',
            child: Icon(
              Icons.settings,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
            ),
          ),
        ],
      ),
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
  final String? album;
  final int? year;
  final String? genre;
  final int? youtubeViewCount;
  final Function(int rating) onRate;
  final Map<int, String> nextIntervals;

  const FlashcardBack({
    super.key,
    required this.title,
    required this.artist,
    this.album,
    this.year,
    this.genre,
    this.youtubeViewCount,
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
            if (album != null) ...[
              const SizedBox(height: 4),
              Text(
                album!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            // Additional metadata
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                if (year != null)
                  _buildMetadataChip(Icons.calendar_today, year.toString()),
                if (genre != null)
                  _buildMetadataChip(Icons.music_note, genre!),
                if (youtubeViewCount != null)
                  _buildMetadataChip(Icons.visibility, _formatViewCount(youtubeViewCount!)),
              ],
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

  Widget _buildMetadataChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewCount(int count) {
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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
    final tooltipMessages = {
      0: 'Complete failure - Start over (1 or A)',
      1: 'Difficult - Review sooner (2 or H)',
      3: 'Good - Standard interval (3 or G)',
      4: 'Easy - Longer interval (4 or E)',
    };

    return Tooltip(
      message: tooltipMessages[rating] ?? '',
      child: ElevatedButton(
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
      ),
    );
  }
}
