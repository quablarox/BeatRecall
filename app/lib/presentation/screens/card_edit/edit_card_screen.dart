import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/repositories/card_repository.dart';

/// Edit Card Screen - Update or delete an existing flashcard.
///
/// **Features:**
/// - @CARDMGMT-003: Card editing
/// - @CARDMGMT-004: Card deletion
class EditCardScreen extends StatefulWidget {
  final Flashcard card;

  const EditCardScreen({
    super.key,
    required this.card,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _youtubeIdController;
  late final TextEditingController _albumController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late final TextEditingController _viewCountController;
  late final TextEditingController _startAtController;
  late final TextEditingController _endAtController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _artistController = TextEditingController(text: widget.card.artist);
    _youtubeIdController = TextEditingController(text: widget.card.youtubeId);
    _albumController = TextEditingController(text: widget.card.album ?? '');
    _yearController = TextEditingController(text: widget.card.year?.toString() ?? '');
    _genreController = TextEditingController(text: widget.card.genre ?? '');
    _viewCountController = TextEditingController(text: widget.card.youtubeViewCount?.toString() ?? '');
    _startAtController = TextEditingController(
      text: widget.card.startAtSecond.toString(),
    );
    _endAtController = TextEditingController(
      text: widget.card.endAtSecond?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _youtubeIdController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _viewCountController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete card',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              key: const Key('edit-card-title'),
              controller: _titleController,
              labelText: 'Title',
              validator: _requiredField('Title'),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              key: const Key('edit-card-artist'),
              controller: _artistController,
              labelText: 'Artist',
              validator: _requiredField('Artist'),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              key: const Key('edit-card-youtube-id'),
              controller: _youtubeIdController,
              labelText: 'YouTube ID',
              helperText: 'Video ID only (not full URL)',
              validator: _requiredField('YouTube ID'),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              key: const Key('edit-card-album'),
              controller: _albumController,
              labelText: 'Album (optional)',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    key: const Key('edit-card-year'),
                    controller: _yearController,
                    labelText: 'Year (optional)',
                    keyboardType: TextInputType.number,
                    validator: _optionalYear('Year'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    key: const Key('edit-card-genre'),
                    controller: _genreController,
                    labelText: 'Genre (optional)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              key: const Key('edit-card-view-count'),
              controller: _viewCountController,
              labelText: 'YouTube View Count (optional)',
              keyboardType: TextInputType.number,
              validator: _optionalNonNegativeNumber('View count'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    key: const Key('edit-card-start-at'),
                    controller: _startAtController,
                    labelText: 'Start at (seconds)',
                    keyboardType: TextInputType.number,
                    validator: _nonNegativeNumber('Start time'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    key: const Key('edit-card-end-at'),
                    controller: _endAtController,
                    labelText: 'End at (seconds)',
                    keyboardType: TextInputType.number,
                    validator: _optionalNonNegativeNumber('End time'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Tooltip(
              message: 'Save card changes',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String labelText,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  String? Function(String?) _requiredField(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      return null;
    };
  }

  String? Function(String?) _nonNegativeNumber(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed < 0) {
        return '$label must be a non-negative number';
      }
      return null;
    };
  }

  String? Function(String?) _optionalNonNegativeNumber(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed < 0) {
        return '$label must be a non-negative number';
      }
      return null;
    };
  }

  String? Function(String?) _optionalYear(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null) {
        return '$label must be a valid year';
      }
      if (parsed < 1000 || parsed > 9999) {
        return '$label must be between 1000 and 9999';
      }
      return null;
    };
  }

  Future<void> _saveChanges() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final startAt = int.parse(_startAtController.text.trim());
    final endAtText = _endAtController.text.trim();
    final endAt = endAtText.isEmpty ? null : int.parse(endAtText);

    final yearText = _yearController.text.trim();
    final year = yearText.isEmpty ? null : int.parse(yearText);

    final genreText = _genreController.text.trim();
    final genre = genreText.isEmpty ? null : genreText;

    final viewCountText = _viewCountController.text.trim();
    final viewCount = viewCountText.isEmpty ? null : int.parse(viewCountText);

    if (endAt != null && endAt < startAt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedCard = widget.card.copyWith(
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      youtubeId: _youtubeIdController.text.trim(),
      album: _albumController.text.trim().isEmpty
          ? null
          : _albumController.text.trim(),
      year: year,
      genre: genre,
      youtubeViewCount: viewCount,
      startAtSecond: startAt,
      endAtSecond: endAt,
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<CardRepository>().save(updatedCard);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card updated'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text(
          'This will permanently delete the card. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<CardRepository>().deleteByUuid(widget.card.uuid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card deleted'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
