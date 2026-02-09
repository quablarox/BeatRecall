import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/route_observer.dart';
import 'dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSummary();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _refreshSummary();
  }

  @override
  void didPopNext() {
    _refreshSummary();
  }

  void _refreshSummary() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardViewModel>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.read<DashboardViewModel>().loadSummary(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(viewModel);
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadSummary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverviewHeader(context, viewModel),
                const SizedBox(height: 16),
                _buildStatGrid(viewModel),
                const SizedBox(height: 24),
                _buildQuickActions(context, viewModel),
                const SizedBox(height: 24),
                _buildLastUpdated(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(DashboardViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Tooltip(
              message: 'Retry loading dashboard',
              child: ElevatedButton.icon(
                onPressed: viewModel.loadSummary,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewHeader(BuildContext context, DashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.library_music,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.dueCards} cards due today',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(DashboardViewModel viewModel) {
    final successRateText = '${(viewModel.successRate * 100).toStringAsFixed(1)}%';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total cards',
                value: viewModel.totalCards.toString(),
                icon: Icons.library_music,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Due cards',
                value: viewModel.dueCards.toString(),
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Success rate',
                value: successRateText,
                icon: Icons.show_chart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Current streak',
                value: viewModel.currentStreak.toString(),
                icon: Icons.local_fire_department,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, DashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: !viewModel.hasCardsToReview
                    ? 'No cards to review'
                    : 'Start reviewing cards',
                child: ElevatedButton.icon(
                  onPressed: !viewModel.hasCardsToReview
                      ? null
                      : () => Navigator.of(context).pushNamed('/quiz'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Review'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Tooltip(
                message: 'View all flashcards',
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/library'),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Library'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Tooltip(
          message: 'Adjust learning and app preferences',
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Tooltip(
          message: 'Import flashcards from CSV file',
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/csv-import'),
              icon: const Icon(Icons.upload_file),
              label: const Text('Import CSV'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(DashboardViewModel viewModel) {
    final updated = viewModel.lastUpdated;
    if (updated == null) return const SizedBox.shrink();

    final time =
        '${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}';

    return Text(
      'Last updated: $time',
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
      textAlign: TextAlign.center,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
