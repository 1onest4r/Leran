import 'package:flutter/material.dart';
import '../obsidian_theme.dart';

class MobileSettingsView extends StatelessWidget {
  const MobileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            Text(
              "Settings",
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage your localized, private configuration settings.",
              style: TextStyle(color: Obsidian.textDim, fontSize: 14),
            ),
            const SizedBox(height: 32), // Tonal Spacing padded
            // Account & Log Out Extracted for complete localize scope

            // Layer 1 - Typography & General Settings Mapping (Unchanged logical shell config )
            _settingBlock(
              header: "APPEARANCE",
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.dark_mode,
                    title: "Dark Mode",
                    active: true,
                  ),
                  _dividerGhost(),
                  _buildItem(
                    icon: Icons.palette,
                    title: "Theme Primary",
                    customAction: const CircleAvatar(
                      backgroundColor: Obsidian.emeraldLight,
                      radius: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECURITY Removed bio map logic

            // Layer 2 Support / Feedback Interaction Map !!
            _settingBlock(
              header: "SUPPORT",
              child: Column(
                children: [
                  InkWell(
                    // Call the dialogue form native generator function securely natively mapping function context variable route
                    onTap: () => _showFeedbackDialog(context),
                    child: _buildItem(
                      icon: Icons.chat_bubble_outline,
                      title: "Send Feedback",
                      sub: "Report a bug or suggest a new feature",
                      chevron: false,
                    ),
                  ),
                  _dividerGhost(),
                  _buildItem(
                    icon: Icons.info_outline,
                    title: "About",
                    sub: "Leran Local Storage Engine\nVersion 1.0.0",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Obsidian.surfaceHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Submit Feedback",
            style: Obsidian.manrope.copyWith(
              color: Obsidian.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            cursorColor: Obsidian.emerald,
            style: const TextStyle(color: Obsidian.text),
            decoration: InputDecoration(
              hintText: "How can we improve?",
              hintStyle: const TextStyle(color: Obsidian.textDim),
              filled: true,
              fillColor: Obsidian.surfaceLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Obsidian.textDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Obsidian.emerald,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Mute execution layer context natively mapped logic logic
                if (controller.text.isNotEmpty) Navigator.pop(context);
              },
              child: const Text(
                "Send",
                style: TextStyle(
                  color: Obsidian.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- CORE UTILITIES UNCHANGED ---

  Widget _settingBlock({String? header, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Obsidian.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Text(
                header,
                style: Obsidian.inter.copyWith(
                  color: Obsidian.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ), // Tone lowered dynamically natively
            ),
            _dividerGhost(),
          ],
          child,
        ],
      ),
    );
  }

  Widget _dividerGhost() =>
      Container(height: 1, color: Obsidian.surfaceHighest.withOpacity(0.4));

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? sub,
    bool chevron = false,
    Widget? customAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Obsidian.textDim),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Obsidian.text,
                    fontWeight: sub != null ? FontWeight.bold : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(color: Obsidian.textDim, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          if (chevron) const Icon(Icons.chevron_right, color: Obsidian.textDim),
          if (customAction != null) customAction,
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool active,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Obsidian.textDim),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Obsidian.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: active,
            onChanged: (val) {},
            activeColor: Obsidian.background,
            activeTrackColor: Obsidian.emerald,
            inactiveTrackColor: Obsidian.surfaceHighest,
          ),
        ],
      ),
    );
  }
}
