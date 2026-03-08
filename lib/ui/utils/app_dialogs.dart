import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

/// UI LAYER: Reusable Popups
class AppDialogs {
  static void showSettings(BuildContext context) {
    final settings = SettingsService();

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedBuilder(
          animation: settings,
          builder: (context, child) {
            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "Settings",
                style: TextStyle(color: settings.textColor),
              ),
              content: SizedBox(
                width: 400,
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                width: 400,
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
