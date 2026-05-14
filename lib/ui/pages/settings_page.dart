import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logic/folder_logic.dart';
import '../../logic/theme_logic.dart';
import '../styling/theme_palette.dart';

class SettingsPage extends StatelessWidget {
  final FolderLogic folderLogic;
  final ThemeLogic themeLogic;

  const SettingsPage({
    super.key,
    required this.folderLogic,
    required this.themeLogic,
  });

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
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
        listenable: Listenable.merge([folderLogic, themeLogic]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader("STORAGE"),
              _settingsCard(context, [
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text("Folder Location"),
                  subtitle: Text(
                    folderLogic.folderPath ?? "No folder selected",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: folderLogic.selectFolder,
                ),
                if (folderLogic.folderPath != null) ...[
                  const Divider(color: Colors.white10, height: 1),
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
              _settingsCard(context, [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text("Dark Mode"),
                  value: themeLogic.isDarkMode,
                  activeColor: primaryColor,
                  onChanged: (v) => themeLogic.toggleTheme(v),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text("Theme Color"),
                  ),
                  subtitle: Wrap(
                    spacing: 12,
                    children: AppTheme.colorOptions.map((color) {
                      final isSelected =
                          themeLogic.primaryColor.value == color.value;
                      return GestureDetector(
                        onTap: () => themeLogic.setPrimaryColor(color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              _sectionHeader("ABOUT"),
              _settingsCard(context, [
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text("Feedback & Support"),
                  subtitle: const Text("Report bugs or request features"),
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onTap: () => _showFeedbackDialog(context),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  // --- NEW EMAIL LAUNCHER LOGIC ---
  Future<void> _launchEmail() async {
    // Replace with your actual support email
    final String targetEmail = '1onest4r.granpad@gmail.com';

    // Formatting the mailto: URL safely
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: targetEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Leran App Feedback',
        'body':
            'Hi there,\n\nI have some feedback regarding the Leran app:\n\n',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint("Could not launch email client: $e");
    }
  }

  // Helper function to safely encode spaces and special characters in the email subject/body
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Send Feedback"),
        content: const Text(
          "Thanks for using Leran!\n\nIf you have any issues or feature requests, please reach out via email.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _launchEmail(); // Trigger the email pop-up!
            },
            child: const Text(
              "Open Gmail / Mail",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDisconnect(BuildContext context) {
    // ... same as before
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

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }
}
