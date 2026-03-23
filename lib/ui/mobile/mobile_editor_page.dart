import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

class MobileEditorPage extends StatelessWidget {
  const MobileEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return Scaffold(
      backgroundColor: settings.scaffoldColor,
      appBar: AppBar(
        backgroundColor: settings.sidebarColor,
        iconTheme: IconThemeData(color: settings.textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.undo, color: settings.dimTextColor),
            onPressed: () {}, // Functionality later
          ),
          IconButton(
            icon: Icon(Icons.redo, color: settings.dimTextColor),
            onPressed: () {}, // Functionality later
          ),
          TextButton(
            onPressed: () {}, // Save functionality later
            child: Text(
              "Save",
              style: TextStyle(
                color: settings.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The Note Title Input
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: TextField(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: settings.textColor,
                ),
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(
                    color: settings.dimTextColor.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            // The Main Note Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    fontSize: 18, // Mobile-friendly font size
                    color: settings.textColor,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: "Start writing...",
                    hintStyle: TextStyle(
                      color: settings.dimTextColor.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
