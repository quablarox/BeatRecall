import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'quiz_viewmodel.dart';
import '../../widgets/flashcard_widget.dart';
import '../../widgets/flashcard_sides.dart';
import '../card_edit/edit_card_screen.dart';

/// Quiz/Review Screen - Main screen for reviewing due flashcards.
/// 
/// **Features:**
/// - @FLASHSYS-001: Dual-sided card interface
/// - @FLASHSYS-002: YouTube media player
/// - @FLASHSYS-003: Answer rating
/// - @DUEQUEUE-001: Due cards retrieval
/// - @DUEQUEUE-002: Review session management
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const Duration _cardAdvanceDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    // Load due cards when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().loadDueCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<QuizViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (viewModel.error != null) {
            return _buildErrorState(viewModel);
          }

          if (viewModel.dueCards.isEmpty) {
            return _buildEmptyState();
          }

          if (viewModel.isSessionComplete) {
            return _buildSessionSummary(viewModel);
          }

          return _buildReviewSession(viewModel);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Review Session'),
      actions: [
        Consumer<QuizViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.dueCards.isEmpty || viewModel.isSessionComplete) {
              return const SizedBox.shrink();
            }

            return Row(
              children: [
                // Edit button for current card
                IconButton(
                  onPressed: () => _navigateToEditCard(context, viewModel),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit card',
                ),
                // Card counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      'Card ${viewModel.currentIndex + 1} of ${viewModel.totalCards}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading due cards...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(QuizViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.error ?? 'An error occurred',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadDueCards(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'All caught up! 🎉',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'You have no cards due for review right now.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Tooltip(
              message: 'Return to dashboard',
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSession(QuizViewModel viewModel) {
    final card = viewModel.currentCard;
    if (card == null) return const SizedBox.shrink();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Handle keyboard shortcuts
          if (event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (!viewModel.showBack) {
              viewModel.flipCard();
              return KeyEventResult.handled;
            }
          }

          if (viewModel.showBack) {
            // Rating shortcuts
            if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                event.logicalKey == LogicalKeyboardKey.keyA) {
              viewModel.rateCard(0, advanceDelay: _cardAdvanceDelay); // Again
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                event.logicalKey == LogicalKeyboardKey.keyH) {
              viewModel.rateCard(1, advanceDelay: _cardAdvanceDelay); // Hard
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.digit3 ||
                event.logicalKey == LogicalKeyboardKey.keyG) {
              viewModel.rateCard(3, advanceDelay: _cardAdvanceDelay); // Good
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.digit4 ||
                event.logicalKey == LogicalKeyboardKey.keyE) {
              viewModel.rateCard(4, advanceDelay: _cardAdvanceDelay); // Easy
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: viewModel.progress,
            backgroundColor: Colors.grey[200],
            minHeight: 4,
          ),
          
          // Flashcard
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlashcardWidget(
                  key: ValueKey(card.uuid), // Force rebuild when card changes
                  showBack: viewModel.showBack,
                  onFlip: viewModel.flipCard,
                  front: FlashcardFront(
                    youtubeId: card.youtubeId,
                    startAtSecond: card.startAtSecond,
                    onShowAnswer: viewModel.flipCard,
                    onUpdateOffset: (newOffset) => viewModel.updateCardOffset(newOffset),
                  ),
                  back: FlashcardBack(
                    title: card.title,
                    artist: card.artist,
                    onRate: (rating) =>
                        viewModel.rateCard(rating, advanceDelay: _cardAdvanceDelay),
                    nextIntervals: viewModel.getNextIntervals(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummary(QuizViewModel viewModel) {
    final duration = viewModel.sessionDuration;
    final durationText = duration != null
        ? '${duration.inMinutes}m ${duration.inSeconds % 60}s'
        : '0s';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Celebration
            const Icon(
              Icons.celebration,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Great job! 🎉',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Session Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('Total cards reviewed', '${viewModel.totalReviewed}'),
                    _buildStatRow('Again', '${viewModel.ratingCounts[0]}', Colors.red),
                    _buildStatRow('Hard', '${viewModel.ratingCounts[1]}', Colors.orange),
                    _buildStatRow('Good', '${viewModel.ratingCounts[3]}', Colors.green),
                    _buildStatRow('Easy', '${viewModel.ratingCounts[4]}', Colors.blue),
                    const Divider(height: 32),
                    _buildStatRow('Time spent', durationText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Actions
            Tooltip(
              message: 'Finish review session',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditCard(BuildContext context, QuizViewModel viewModel) async {
    final currentCard = viewModel.currentCard;
    if (currentCard == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCardScreen(card: currentCard),
      ),
    );

    // Reload due cards if card was updated or deleted
    if (result == true && context.mounted) {
      await viewModel.loadDueCards();
    }
  }
}
