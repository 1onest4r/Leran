import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../logic/vault_controller.dart';

class MobileSettingsPage extends StatelessWidget {
  const MobileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final vault = VaultController();

    // Use AnimatedBuilder to live-update if toggles are changed
    return AnimatedBuilder(
      animation: Listenable.merge([settings, vault]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: settings.scaffoldColor,
          appBar: AppBar(
            backgroundColor: settings.sidebarColor,
            elevation: 0,
            iconTheme: IconThemeData(color: settings.textColor),
            title: Text(
              "Settings",
              style: TextStyle(
                color: settings.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // APPEARANCE SECTION
              _buildSectionHeader(settings, "Appearance & Behavior"),
              SwitchListTile(
                title: Text(
                  "Dark Mode",
                  style: TextStyle(color: settings.textColor),
                ),
                activeColor: settings.accentColor,
                value: settings.isDarkMode,
                onChanged: (val) => settings.toggleTheme(val),
              ),
              SwitchListTile(
                title: Text(
                  "Auto Save Notes",
                  style: TextStyle(color: settings.textColor),
                ),
                subtitle: Text(
                  "Save seamlessly while typing",
                  style: TextStyle(color: settings.dimTextColor, fontSize: 13),
                ),
                activeColor: settings.accentColor,
                value: settings.autoSave,
                onChanged: (val) => settings.toggleAutoSave(val),
              ),

              const SizedBox(height: 16),

              // EDITOR SECTION
              _buildSectionHeader(settings, "Editor Typography"),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Editor Font Size: ${settings.fontSize.toInt()}",
                      style: TextStyle(color: settings.textColor),
                    ),
                    Slider(
                      value: settings.fontSize,
                      min: 10,
                      max: 32, // Adjusted max for mobile
                      divisions: 22,
                      activeColor: settings.accentColor,
                      inactiveColor: settings.dimTextColor.withOpacity(0.3),
                      onChanged: (val) => settings.setFontSize(val),
                    ),
                  ],
                ),
              ),

              Divider(color: settings.dividerColor, height: 32),

              // STORAGE / VAULT SECTION
              _buildSectionHeader(settings, "Storage Management"),
              ListTile(
                title: Text(
                  "Working Vault Directory",
                  style: TextStyle(color: settings.textColor),
                ),
                subtitle: Text(
                  vault.selectedDirectory ?? "No active directory selected.",
                  style: TextStyle(color: settings.dimTextColor, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: settings.textColor,
                    side: BorderSide(color: settings.dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Change Active Folder"),
                  onPressed: () {
                    // Note: Mobile 'Change Folder' logic triggered here!
                    // await FilePicker.platform.getDirectoryPath();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(SettingsService settings, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: settings.accentColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
