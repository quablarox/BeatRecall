import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/flashcard.dart';

/// List item widget for displaying a flashcard in the library.
class CardListItem extends StatelessWidget {
  final Flashcard card;
  final VoidCallback onTap;

  const CardListItem({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getCardStatus();
    final statusColor = _getStatusColor();
    final isDueToday = _isDueToday();
    final isOverdue = _isOverdue();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            _getStatusIcon(),
            color: statusColor,
          ),
        ),
        title: Text(
          card.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.artist),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(status, statusColor),
                const SizedBox(width: 8),
                if (isDueToday || isOverdue)
                  _buildDueChip(isDueToday, isOverdue),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDueDate(),
              style: TextStyle(
                fontSize: 12,
                color: isOverdue ? Colors.red : Colors.grey,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'EF: ${card.easeFactor.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getCardStatus() {
    if (card.repetitions == 0) return 'New';
    if (card.repetitions < 3) return 'Learning';
    return 'Review';
  }

  Color _getStatusColor() {
    if (card.repetitions == 0) return Colors.blue;
    if (card.repetitions < 3) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (card.repetitions == 0) return Icons.fiber_new;
    if (card.repetitions < 3) return Icons.school;
    return Icons.check_circle;
  }

  bool _isDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      card.nextReviewDate.year,
      card.nextReviewDate.month,
      card.nextReviewDate.day,
    );
    return dueDate == today;
  }

  bool _isOverdue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return card.nextReviewDate.isBefore(today);
  }

  String _formatDueDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      card.nextReviewDate.year,
      card.nextReviewDate.month,
      card.nextReviewDate.day,
    );

    final difference = dueDate.difference(today).inDays;

    if (difference == 0) return 'Due today';
    if (difference == -1) return '1 day overdue';
    if (difference < 0) return '${-difference} days overdue';
    if (difference == 1) return 'Due tomorrow';
    if (difference <= 7) return 'Due in $difference days';
    
    return DateFormat('MMM d').format(card.nextReviewDate);
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDueChip(bool isDueToday, bool isOverdue) {
    final color = isOverdue ? Colors.red : Colors.amber;
    final text = isOverdue ? 'Overdue' : 'Today';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
