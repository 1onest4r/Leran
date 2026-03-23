import 'package:flutter/material.dart';
import '../../../services/settings_service.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String subtitleText;
  final String timeText;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.subtitleText,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Use slightly lighter surface area than scaffold background
                color: settings.sidebarColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: settings.dividerColor, width: 0.5),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: settings.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Center(
            child: Text(
              subtitleText,
              style: TextStyle(
                color: settings.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),

          Center(
            child: Text(
              timeText,
              style: TextStyle(color: settings.dimTextColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
