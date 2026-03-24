import 'dart:ui';
import 'package:flutter/material.dart';
import 'obsidian_theme.dart';
import 'views/mobile_vault_view.dart';
import 'views/mobile_search_view.dart';
import 'views/mobile_settings_view.dart';
import 'views/mobile_tags_view.dart'; // <--- NEW FOLDER TAB IMPORTED

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MobileVaultView(),
    MobileSearchView(),
    MobileTagsView(), // <--- ASSIGNED FOLDERS TAB HERE
    MobileSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Obsidian.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildGlassmorphicBottomBar(),
    );
  }

  Widget _buildGlassmorphicBottomBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Obsidian.background.withOpacity(0.7),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.description_outlined, Icons.description),
              _navItem(1, Icons.search_outlined, Icons.search),
              _navItem(
                2,
                Icons.folder_copy_outlined,
                Icons.folder_copy,
              ), // Updated Label icon to Folder Icon
              _navItem(3, Icons.settings_outlined, Icons.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData inactiveIcon, IconData activeIcon) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Obsidian.emerald : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? Obsidian.background : Obsidian.textDim,
          size: 26,
        ),
      ),
    );
  }
}
