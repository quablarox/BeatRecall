import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A flashcard widget that displays front and back sides with a flip animation.
/// 
/// **Feature:** @FLASHSYS-001 (Dual-Sided Card Interface)
/// 
/// **Front side:** Shows the content that triggers recall (e.g., YouTube player)
/// **Back side:** Shows the answer (title, artist, rating buttons)
class FlashcardWidget extends StatefulWidget {
  /// Content to display on the front of the card
  final Widget front;
  
  /// Content to display on the back of the card
  final Widget back;
  
  /// Whether the card should start showing the back side
  final bool showBack;
  
  /// Callback when the card is flipped
  final VoidCallback? onFlip;
  
  /// Duration of the flip animation
  final Duration flipDuration;

  const FlashcardWidget({
    super.key,
    required this.front,
    required this.back,
    this.showBack = false,
    this.onFlip,
    this.flipDuration = const Duration(milliseconds: 600),
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _showBack = widget.showBack;
    
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_showBack) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBack != oldWidget.showBack) {
      _flip(notifyParent: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip({bool notifyParent = true}) {
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
    if (notifyParent) {
      widget.onFlip?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation angle
          final angle = _animation.value * math.pi;
          
          // Determine which side to show based on rotation
          final showFront = angle < math.pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: showFront
                ? widget.front
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

/// Card side container with consistent styling
class FlashcardSide extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FlashcardSide({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600, // Max width for desktop
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
