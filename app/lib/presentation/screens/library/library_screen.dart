import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'library_viewmodel.dart';
import 'widgets/card_list_item.dart';

/// Library Screen - Display and manage flashcard collection.
/// 
/// **Features:**
/// - @CARDMGMT-005: Search and filter flashcards
/// - Display all cards in list format
/// - Real-time search (title/artist)
/// - Filter by status and due date
/// - Sort options
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load cards when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryViewModel>().loadCards();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.of(context).pushNamed('/quiz');
            },
            tooltip: 'Start Review',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Reset Progress (Debug)',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add card screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add card - Coming soon')),
              );
            },
            tooltip: 'Add card',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildResultCount(),
          Expanded(child: _buildCardList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/csv-import');
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Import CSV'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<LibraryViewModel>(
        builder: (context, viewModel, child) {
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title or artist...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              viewModel.setSearchQuery(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<LibraryViewModel>(
      builder: (context, viewModel, child) {
        final hasActiveFilters = viewModel.statusFilter != null ||
            viewModel.dueDateFilter != DueDateFilter.all;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  if (hasActiveFilters)
                    TextButton.icon(
                      onPressed: () => viewModel.clearFilters(),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Status filters
                    _buildFilterChip(
                      label: 'New',
                      selected: viewModel.statusFilter == CardStatus.newCard,
                      onSelected: (selected) {
                        viewModel.setStatusFilter(
                          selected ? CardStatus.newCard : null,
                        );
                      },
                    ),
                    _buildFilterChip(
                      label: 'Learning',
                      selected: viewModel.statusFilter == CardStatus.learning,
                      onSelected: (selected) {
                        viewModel.setStatusFilter(
                          selected ? CardStatus.learning : null,
                        );
                      },
                    ),
                    _buildFilterChip(
                      label: 'Review',
                      selected: viewModel.statusFilter == CardStatus.review,
                      onSelected: (selected) {
                        viewModel.setStatusFilter(
                          selected ? CardStatus.review : null,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Due date filters
                    _buildFilterChip(
                      label: 'Due Today',
                      selected: viewModel.dueDateFilter == DueDateFilter.dueToday,
                      onSelected: (selected) {
                        viewModel.setDueDateFilter(
                          selected ? DueDateFilter.dueToday : DueDateFilter.all,
                        );
                      },
                    ),
                    _buildFilterChip(
                      label: 'Overdue',
                      selected: viewModel.dueDateFilter == DueDateFilter.overdue,
                      onSelected: (selected) {
                        viewModel.setDueDateFilter(
                          selected ? DueDateFilter.overdue : DueDateFilter.all,
                        );
                      },
                    ),
                    _buildFilterChip(
                      label: 'This Week',
                      selected: viewModel.dueDateFilter == DueDateFilter.dueThisWeek,
                      onSelected: (selected) {
                        viewModel.setDueDateFilter(
                          selected ? DueDateFilter.dueThisWeek : DueDateFilter.all,
                        );
                      },
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  Widget _buildResultCount() {
    return Consumer<LibraryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Showing ${viewModel.filteredCardCount} of ${viewModel.totalCardCount} cards',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  Widget _buildCardList() {
    return Consumer<LibraryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(viewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadCards(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.filteredCards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.library_music, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  viewModel.totalCardCount == 0
                      ? 'No cards yet'
                      : 'No cards match your filters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (viewModel.totalCardCount == 0)
                  const Text('Import a CSV or add cards manually'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.filteredCards.length,
          itemBuilder: (context, index) {
            final card = viewModel.filteredCards[index];
            return CardListItem(
              card: card,
              onTap: () {
                // TODO: Navigate to card details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped: ${card.title}')),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSortOptions() {
    final viewModel = context.read<LibraryViewModel>();
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSortOption('Title (A-Z)', SortOption.alphabeticalAZ, viewModel),
            _buildSortOption('Title (Z-A)', SortOption.alphabeticalZA, viewModel),
            _buildSortOption('Artist (A-Z)', SortOption.artistAZ, viewModel),
            _buildSortOption('Due Date (Oldest)', SortOption.dueDateOldest, viewModel),
            _buildSortOption('Due Date (Newest)', SortOption.dueDateNewest, viewModel),
            _buildSortOption('Created (Newest)', SortOption.createdNewest, viewModel),
            _buildSortOption('Created (Oldest)', SortOption.createdOldest, viewModel),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(String label, SortOption option, LibraryViewModel viewModel) {
    final isSelected = viewModel.sortOption == option;
    
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        viewModel.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Learning Progress'),
        content: const Text(
          'This will reset all cards to "due now" and clear all SRS progress.\n\n'
          'This action cannot be undone!\n\n'
          '⚠️ Debug feature only',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resetting progress...')),
              );
              
              try {
                await context.read<LibraryViewModel>().resetAllProgress();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ All progress reset successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }
}
