import 'package:flutter/material.dart';

class MobileLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final List<Widget> pages;

  const MobileLayout({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // NEW: This detects the height of the phone's 3-button bar or gesture pill
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, minHeight: 480),
        child: pages[currentIndex],
      ),
      bottomNavigationBar: Container(
        // We dynamically add the OS padding to our desired 70px height
        // so the background color extends beautifully behind the buttons
        height: 70 + bottomPadding,
        color: theme.scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: bottomPadding, // This pushes our icons UP and out of the way!
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(context, Icons.description_outlined, 0),
            _navIcon(context, Icons.search, 1),
            _navIcon(context, Icons.folder_outlined, 2),
            _navIcon(context, Icons.sync, 3),
            _navIcon(context, Icons.settings_outlined, 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, int index) {
    bool isActive = currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
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
