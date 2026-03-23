import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/settings_service.dart';
import '../../../logic/vault_controller.dart';

class AppDialogs {
  static void showSettings(BuildContext context) {
    final settings = SettingsService();
    final vault = VaultController();
    final scale = settings.uiScale;

    showDialog(
      context: context,
      builder: (context) {
        // We now listen to both Settings AND VaultController
        // so the path updates if they change it without closing the dialog
        return AnimatedBuilder(
          animation: Listenable.merge([settings, vault]),
          builder: (context, child) {
            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "Settings",
                style: TextStyle(color: settings.textColor),
              ),
              content: SizedBox(
                width: 450 * scale, // Made slightly wider for long file paths
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(color: settings.textColor),
                      ),
                      value: settings.isDarkMode,
                      activeColor: settings.accentColor,
                      onChanged: (val) => settings.toggleTheme(val),
                    ),
                    SwitchListTile(
                      title: Text(
                        "Auto Save",
                        style: TextStyle(color: settings.textColor),
                      ),
                      subtitle: Text(
                        "Save while typing",
                        style: TextStyle(
                          color: settings.dimTextColor,
                          fontSize: 12,
                        ),
                      ),
                      value: settings.autoSave,
                      activeColor: settings.accentColor,
                      onChanged: (val) => settings.toggleAutoSave(val),
                    ),
                    Divider(color: settings.dividerColor),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0 * scale,
                        horizontal: 16.0 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "UI Scale: ${(settings.uiScale * 100).toInt()}%",
                            style: TextStyle(color: settings.textColor),
                          ),
                          Slider(
                            value: settings.uiScale,
                            min: 0.8,
                            max: 1.5,
                            divisions: 7,
                            activeColor: settings.accentColor,
                            inactiveColor: settings.dimTextColor.withOpacity(
                              0.2,
                            ),
                            onChanged: (val) => settings.setUiScale(val),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: settings.dividerColor),

                    // --- NEW: VAULT CHANGER ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0 * scale,
                        horizontal: 16.0 * scale,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Working Directory",
                                  style: TextStyle(
                                    color: settings.textColor,
                                    fontSize: 16 * scale,
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  vault.selectedDirectory ??
                                      "No Vault Selected",
                                  style: TextStyle(
                                    color: settings.dimTextColor,
                                    fontSize: 12 * scale,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16 * scale),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: settings.accentColor,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              String? result = await FilePicker.platform
                                  .getDirectoryPath();
                              if (result != null) {
                                vault.setVaultDirectory(result);
                                // Automatically close Settings to let the user see their new Vault
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text("Change"),
                          ),
                        ],
                      ),
                    ),
                    // --------------------------
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: TextStyle(color: settings.accentColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<String?> showNewNoteDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final RegExp invalidChars = RegExp(r'[<>:"/\\|?*]');
    final settings = SettingsService();
    final scale = settings.uiScale;

    return showDialog<String>(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            void submit() {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              if (invalidChars.hasMatch(text)) {
                setState(() => errorText = "Invalid characters");
                return;
              }
              Navigator.pop(context, text);
            }

            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "New Note",
                style: TextStyle(color: settings.textColor),
              ),
              content: SizedBox(
                width: 400 * scale,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: settings.textColor),
                  cursorColor: settings.accentColor,
                  onSubmitted: (_) => submit(),
                  onChanged: (_) {
                    if (errorText != null) setState(() => errorText = null);
                  },
                  decoration: InputDecoration(
                    hintText: "Enter filename...",
                    hintStyle: TextStyle(color: settings.dimTextColor),
                    errorText: errorText,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: settings.dimTextColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: settings.accentColor),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: settings.dimTextColor),
                  ),
                ),
                TextButton(
                  onPressed: submit,
                  child: Text(
                    "Create",
                    style: TextStyle(color: settings.accentColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<bool> showDeleteConfirmation(BuildContext context) async {
    final settings = SettingsService();
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: settings.sidebarColor,
            title: Text(
              "Delete Note?",
              style: TextStyle(color: settings.textColor),
            ),
            content: Text(
              "This cannot be undone.",
              style: TextStyle(color: settings.dimTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: settings.dimTextColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
