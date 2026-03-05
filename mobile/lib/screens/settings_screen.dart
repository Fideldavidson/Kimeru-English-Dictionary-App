import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/local_database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  bool _isSyncing = false;
  String? _syncMessage;

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    try {
      final count = await _dbService.syncWithRemote();
      setState(() {
        _syncMessage = count > 0 
            ? 'Successfully synced $count words!' 
            : 'Dictionary is up to date';
        _isSyncing = false;
      });
    } catch (e) {
      setState(() {
        _syncMessage = 'Sync failed: ${e.toString()}';
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark themes'),
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.toggleTheme(value),
                  secondary: const Icon(Icons.brightness_4),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Font Size'),
                  subtitle: Text('Current scale: ${settings.fontSizeMultiplier.toStringAsFixed(1)}x'),
                  leading: const Icon(Icons.format_size),
                  trailing: DropdownButton<double>(
                    value: settings.fontSizeMultiplier,
                    items: const [
                      DropdownMenuItem(value: 0.8, child: Text('Small')),
                      DropdownMenuItem(value: 1.0, child: Text('Medium')),
                      DropdownMenuItem(value: 1.2, child: Text('Large')),
                      DropdownMenuItem(value: 1.4, child: Text('Extra Large')),
                    ],
                    onChanged: (value) {
                      if (value != null) settings.setFontSizeMultiplier(value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Data & Sync'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Sync Dictionary'),
                  subtitle: const Text('Check for updates from GitHub'),
                  leading: const Icon(Icons.sync),
                  trailing: _isSyncing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                  onTap: _isSyncing ? null : _handleSync,
                ),
                if (_syncMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _syncMessage!,
                      style: TextStyle(
                        color: _syncMessage!.contains('failed') ? Colors.red : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'About'),
          const Card(
            child: ListTile(
              title: Text('Kimeru Dictionary'),
              subtitle: Text('Version 1.1.0 (Senior Build)'),
              leading: Icon(Icons.info_outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
