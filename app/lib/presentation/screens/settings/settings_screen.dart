import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/settings_service.dart';

/// Settings Screen - Configure app preferences
/// 
/// **Features:**
/// - @SETTINGS-001: Daily new cards limit
/// - @SETTINGS-002: Audio-only mode
/// - @SETTINGS-003: General preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          final settings = settingsService.settings;

          return ListView(
            children: [
              // Learning Section
              _buildSectionHeader('Learning'),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('New Cards Per Day'),
                subtitle: Text('Current: ${settings.newCardsPerDay} cards'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showNewCardsDialog(context, settingsService),
              ),
              Consumer<SettingsService>(
                builder: (context, service, child) {
                  final remaining = service.getRemainingNewCardsToday();
                  return ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('New Cards Remaining Today'),
                    subtitle: Text(
                      '$remaining cards remaining',
                      style: TextStyle(
                        color: remaining == 0 ? Colors.orange : null,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Media Section
              _buildSectionHeader('Media'),
              SwitchListTile(
                secondary: const Icon(Icons.audio_file),
                title: const Text('Audio-Only Mode'),
                subtitle: const Text('Hide video player, save bandwidth'),
                value: settings.audioOnlyMode,
                onChanged: (value) => settingsService.setAudioOnlyMode(value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.play_arrow),
                title: const Text('Auto-Play Videos'),
                subtitle: const Text('Play automatically when card appears'),
                value: settings.autoPlayVideo,
                onChanged: (value) => settingsService.setAutoPlayVideo(value),
              ),
              const Divider(),

              // Appearance Section
              _buildSectionHeader('Appearance'),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(_getThemeDisplayName(settings.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, settingsService),
              ),
              const Divider(),

              // About Section
              _buildSectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                subtitle: const Text('1.0.0+1'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Open Source'),
                subtitle: const Text('Built with Flutter & ❤️'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Author'),
                subtitle: const Text('Hongy Rox'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getThemeDisplayName(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System Default';
    }
  }

  Future<void> _showNewCardsDialog(
    BuildContext context,
    SettingsService settingsService,
  ) async {
    final controller = TextEditingController(
      text: settingsService.settings.newCardsPerDay.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Cards Per Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set how many new cards you want to learn each day. '
              'This helps pace your learning.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New cards per day',
                hintText: '0-999',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 999) {
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a number between 0 and 999'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await settingsService.setNewCardsPerDay(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New cards per day set to $result'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showThemeDialog(
    BuildContext context,
    SettingsService settingsService,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: settingsService.settings.themeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: settingsService.settings.themeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              groupValue: settingsService.settings.themeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await settingsService.setThemeMode(result);
    }
  }
}
