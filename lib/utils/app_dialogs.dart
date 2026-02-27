import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class AppDialogs {
  // 1. SETTINGS DIALOG
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
                    // Theme
                    SwitchListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(color: settings.textColor),
                      ),
                      value: settings.isDarkMode,
                      activeColor: settings.accentColor,
                      onChanged: (val) => settings.toggleTheme(val),
                    ),
                    // Auto-Save
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
                    // Font Size
                    ListTile(
                      title: Text(
                        "Font Size: ${settings.fontSize.toInt()}",
                        style: TextStyle(color: settings.textColor),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: settings.textColor),
                            onPressed: () =>
                                settings.setFontSize(settings.fontSize - 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: settings.textColor),
                            onPressed: () =>
                                settings.setFontSize(settings.fontSize + 1),
                          ),
                        ],
                      ),
                    ),
                    // Font Family
                    ListTile(
                      title: Text(
                        "Font Family",
                        style: TextStyle(color: settings.textColor),
                      ),
                      trailing: DropdownButton<String>(
                        dropdownColor: settings.sidebarColor,
                        value: settings.fontFamily,
                        style: TextStyle(color: settings.textColor),
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Courier',
                            child: Text("Courier"),
                          ),
                          DropdownMenuItem(
                            value: 'Roboto',
                            child: Text("Roboto"),
                          ),
                          DropdownMenuItem(
                            value: 'monospace',
                            child: Text("Monospace"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) settings.setFontFamily(val);
                        },
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

  // 2. NEW NOTE DIALOG (Fixed Enter Key)
  static Future<String?> showNewNoteDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final RegExp invalidChars = RegExp(r'[<>:"/\\|?*]');
    final settings = SettingsService(); // Access colors

    return showDialog<String>(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            // The shared logic for Enter Key and Button Click
            void submit() {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              if (invalidChars.hasMatch(text)) {
                setState(() => errorText = "Invalid characters");
                return;
              }
              Navigator.pop(context, text); // Return valid name
            }

            return AlertDialog(
              backgroundColor: settings.sidebarColor,
              title: Text(
                "New Note",
                style: TextStyle(color: settings.textColor),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: settings.textColor),
                cursorColor: settings.accentColor,
                // FIX: Listen for Enter Key
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: settings.dimTextColor),
                  ),
                ),
                TextButton(
                  onPressed: submit, // Call shared logic
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

  // 3. DELETE CONFIRMATION
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
