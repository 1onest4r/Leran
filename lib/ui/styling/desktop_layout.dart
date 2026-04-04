import 'package:flutter/material.dart';
import 'theme_palette.dart';

class DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final List<Widget> pages;

  const DesktopLayout({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 360, minWidth: 500),
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 80,
              color: const Color(
                0xFF1A1A1A,
              ), // Slightly lighter than background
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navIcon(Icons.description_outlined, 0),
                  const SizedBox(height: 20),
                  _navIcon(Icons.search, 1),
                  const SizedBox(height: 20),
                  _navIcon(Icons.folder_outlined, 2),
                  const SizedBox(height: 20),
                  _navIcon(Icons.settings_outlined, 3),
                ],
              ),
            ),
            // Main Content Area
            Expanded(child: pages[currentIndex]),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
