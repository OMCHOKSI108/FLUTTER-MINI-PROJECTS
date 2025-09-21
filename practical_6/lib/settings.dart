import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool)? onThemeToggle;

  const SettingsScreen({Key? key, this.onThemeToggle}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _rememberLogin = false;
  bool _enableNotifications = true;
  double _fontSize = 16.0;
  int _autoSaveInterval = 30; // seconds
  String _userName = '';
  List<String> _favoriteCategories = [];

  final List<String> _availableCategories = [
    'Personal',
    'Work',
    'Study',
    'Ideas',
    'Shopping',
    'Travel',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _rememberLogin = prefs.getBool('remember') ?? false;
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _fontSize = prefs.getDouble('font_size') ?? 16.0;
      _autoSaveInterval = prefs.getInt('auto_save_interval') ?? 30;
      _userName = prefs.getString('name') ?? '';
      _favoriteCategories = prefs.getStringList('favorite_categories') ?? [];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setBool('enable_notifications', _enableNotifications);
    await prefs.setDouble('font_size', _fontSize);
    await prefs.setInt('auto_save_interval', _autoSaveInterval);
    await prefs.setStringList('favorite_categories', _favoriteCategories);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will remove all notes, settings, and login data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully!'),
          backgroundColor: Colors.orange,
        ),
      );

      // Navigate back to login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Information Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Name: ${_userName.isEmpty ? 'Not logged in' : _userName}',
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Remember Login'),
                    subtitle: const Text('Keep me logged in'),
                    value: _rememberLogin,
                    onChanged: null, // Read-only display
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Appearance Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                      widget.onThemeToggle?.call(value);
                    },
                  ),
                  ListTile(
                    title: const Text('Font Size'),
                    subtitle: Text('${_fontSize.toInt()}px'),
                    trailing: SizedBox(
                      width: 150,
                      child: Slider(
                        value: _fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        label: '${_fontSize.toInt()}px',
                        onChanged: (value) => setState(() => _fontSize = value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Behavior Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Behavior',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Get notified about app updates'),
                    value: _enableNotifications,
                    onChanged: (value) =>
                        setState(() => _enableNotifications = value),
                  ),
                  ListTile(
                    title: const Text('Auto-save Interval'),
                    subtitle: Text('Save notes every ${_autoSaveInterval}s'),
                    trailing: DropdownButton<int>(
                      value: _autoSaveInterval,
                      items: [15, 30, 60, 120].map((seconds) {
                        return DropdownMenuItem(
                          value: seconds,
                          child: Text('${seconds}s'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _autoSaveInterval = value ?? 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Favorite Categories Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorite Note Categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    children: _availableCategories.map((category) {
                      final isSelected = _favoriteCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _favoriteCategories.add(category);
                            } else {
                              _favoriteCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_favoriteCategories.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Storage Information Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Shared Preferences Demo'),
                    subtitle: const Text(
                      'This app demonstrates storing various data types:\n'
                      '• Boolean: Dark mode, notifications\n'
                      '• String: User name, login data\n'
                      '• Double: Font size\n'
                      '• Int: Auto-save interval\n'
                      '• String List: Categories, notes (JSON)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Danger Zone
          Card(
            color: Colors.red.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _clearAllData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Data'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
