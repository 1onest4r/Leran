import 'package:flutter/material.dart';
import '../../logic/folder_logic.dart';

class SettingsPage extends StatelessWidget {
  final FolderLogic folderLogic;

  const SettingsPage({super.key, required this.folderLogic});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Manage your localized, private configuration settings.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: folderLogic,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader("STORAGE"),
              _settingsCard([
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text("Folder Location"),
                  subtitle: Text(
                    folderLogic.folderPath ?? "No folder selected",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: folderLogic.selectFolder, // Triggers directory swap
                ),
                if (folderLogic.folderPath != null) ...[
                  const Divider(
                    color: Color.fromARGB(255, 71, 71, 71),
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.folder_off,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      "Disconnect Folder",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () => _confirmDisconnect(context),
                  ),
                ],
              ]),
              const SizedBox(height: 20),
              _sectionHeader("APPEARANCE"),
              _settingsCard([
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text("Dark Mode"),
                  value: true,
                  activeColor: primaryColor,
                  onChanged: (v) {},
                ),
                const Divider(
                  color: Color.fromARGB(255, 71, 71, 71),
                  height: 1,
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text("Theme Primary"),
                  trailing: CircleAvatar(
                    radius: 8,
                    backgroundColor: primaryColor,
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  void _confirmDisconnect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Disconnect Folder?"),
        content: const Text(
          "This won't delete your .md files, but it will clear them from the app's view.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              folderLogic.disconnectFolder();
              Navigator.pop(context);
            },
            child: const Text(
              "Disconnect",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }
}
