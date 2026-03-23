import 'package:flutter/material.dart';
import 'package:flutter_demo/ui/mobile/mobile_search_page.dart';
import '../../../services/settings_service.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return Drawer(
      backgroundColor: settings.sidebarColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: const EdgeInsets.all(20),
                icon: Icon(
                  Icons.settings_outlined,
                  color: settings.textColor,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileSearchPage(),
                    ),
                  );
                },
              ),
            ),

            _drawerTile(settings, Icons.description_outlined, "All notes", "3"),
            _drawerTile(
              settings,
              Icons.group_outlined,
              "Shared notes",
              "BETA",
              isBeta: true,
            ),
            _drawerTile(settings, Icons.delete_outline, "Recycle bin", "1"),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(color: settings.dividerColor, height: 1),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // Very subtle greenish wash behind highlighted selected route
                color: settings.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _drawerTile(
                settings,
                Icons.folder_open_outlined,
                "Folders",
                "3",
                isSelected: true,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: settings.scaffoldColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: settings.dividerColor),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {},
                child: Text(
                  "Manage folders",
                  style: TextStyle(
                    color: settings.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    SettingsService settings,
    IconData icon,
    String title,
    String trailingInfo, {
    bool isSelected = false,
    bool isBeta = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? settings.accentColor : settings.textColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? settings.accentColor : settings.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isBeta
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: settings.accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trailingInfo,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Text(
              trailingInfo,
              style: TextStyle(
                color: settings.dimTextColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
      onTap: () {},
    );
  }
}
