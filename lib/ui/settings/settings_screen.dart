import 'package:flutter/material.dart';
import 'package:flutter_demo/ui/settings/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final manager = SettingsManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Theme"),
            subtitle: Text("Light mode"),
            onTap: () async {
              final theme = await _showThemeDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<ThemeMode?> _showThemeDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(value: ThemeMode.light),
            ButtonSegment(value: ThemeMode.system),
            ButtonSegment(value: ThemeMode.dark),
          ],
          selected: {manager.currentTheme},
          onSelectionChanged: (Set<ThemeMode> selection) {
            manager.setTheme(selection.first);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
