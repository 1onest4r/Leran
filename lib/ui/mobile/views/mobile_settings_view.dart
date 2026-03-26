import 'package:flutter/material.dart';
import '../obsidian_theme.dart';
import '../../../services/settings_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileSettingsView extends StatelessWidget {
  const MobileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get reference to SettingsService
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
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
                const SizedBox(height: 32),

                _settingBlock(
                  header: "APPEARANCE",
                  child: Column(
                    children: [
                      _buildToggleItem(
                        icon: Icons.dark_mode,
                        title: "Dark Mode",
                        active: settings.isDarkMode,
                        onChanged: (val) {
                          settings.toggleDarkMode();
                        },
                      ),
                      _dividerGhost(),
                      // 2. Wrap this with InkWell and call the bottom sheet
                      InkWell(
                        onTap: () => _showColorPicker(context, settings),
                        child: _buildItem(
                          icon: Icons.palette,
                          title: "Theme Primary",
                          customAction: CircleAvatar(
                            backgroundColor: Obsidian
                                .emerald, // Now previews the selected theme color!
                            radius: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _settingBlock(
                  header: "SUPPORT",
                  child: Column(
                    children: [
                      InkWell(
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
      },
    );
  }

  // 3. The beautiful bottom sheet color picker
  void _showColorPicker(BuildContext context, SettingsService settings) {
    final options = [
      {'color': AppAccentColor.emerald, 'name': 'Emerald'},
      {'color': AppAccentColor.amethyst, 'name': 'Amethyst'},
      {'color': AppAccentColor.sapphire, 'name': 'Sapphire'},
      {'color': AppAccentColor.ruby, 'name': 'Ruby'},
      {'color': AppAccentColor.topaz, 'name': 'Topaz'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Obsidian.surfaceHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Accent Gem",
                style: Obsidian.manrope.copyWith(
                  color: Obsidian.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: options.map((option) {
                  final colorEnum = option['color'] as AppAccentColor;
                  final isSelected = settings.appAccentColor == colorEnum;

                  // Define exact hex colors for the picker swatches
                  Color swatchColor;
                  switch (colorEnum) {
                    case AppAccentColor.amethyst:
                      swatchColor = const Color(0xFF8B5CF6);
                      break;
                    case AppAccentColor.sapphire:
                      swatchColor = const Color(0xFF3B82F6);
                      break;
                    case AppAccentColor.ruby:
                      swatchColor = const Color(0xFFEF4444);
                      break;
                    case AppAccentColor.topaz:
                      swatchColor = const Color(0xFFF59E0B);
                      break;
                    default:
                      swatchColor = const Color(0xFF10B981);
                      break;
                  }

                  return GestureDetector(
                    onTap: () {
                      settings.setAppAccentColor(
                        colorEnum,
                      ); // Change color dynamically
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isSelected
                              ? Obsidian.text
                              : Colors.transparent,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: swatchColor,
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: settings.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['name'] as String,
                          style: Obsidian.inter.copyWith(
                            color: isSelected
                                ? Obsidian.text
                                : Obsidian.textDim,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
            style: TextStyle(color: Obsidian.text),
            decoration: InputDecoration(
              hintText: "How can we improve?",
              hintStyle: TextStyle(color: Obsidian.textDim),
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
              child: Text(
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
              onPressed: () async {
                final feedbackText = controller.text.trim();
                if (feedbackText.isNotEmpty) {
                  // 1. Construct the mailto URI
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path:
                        '1onest4r.granpad@gmail.com', // ⚠️ REPLACE WITH YOUR EMAIL
                    query:
                        'subject=Obsidian%20App%20Feedback&body=${Uri.encodeComponent(feedbackText)}',
                  );

                  // 2. Launch the email client
                  try {
                    await launchUrl(emailUri);
                  } catch (e) {
                    debugPrint("Could not launch email client");
                  }

                  // 3. Close the dialog
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(
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
              ),
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
          if (chevron) Icon(Icons.chevron_right, color: Obsidian.textDim),
          if (customAction != null) customAction,
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool active,
    ValueChanged<bool>? onChanged,
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
              style: TextStyle(
                color: Obsidian.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: active,
            onChanged: onChanged ?? (val) {},
            activeColor: Obsidian.background,
            activeTrackColor: Obsidian.emerald,
            inactiveTrackColor: Obsidian.surfaceHighest,
          ),
        ],
      ),
    );
  }
}
