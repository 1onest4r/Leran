import 'package:flutter/material.dart';
import 'package:leran/logic/folder_logic.dart';

// 1. REMOVED the 'dart:io' import!

import '../pages/cluster_page.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';
import 'desktop_layout.dart';
import 'mobile_layout.dart';

class LayoutManager extends StatefulWidget {
  const LayoutManager({super.key});

  @override
  State<LayoutManager> createState() => _LayoutManagerState();
}

class _LayoutManagerState extends State<LayoutManager> {
  int _currentIndex = 0;

  final FolderLogic _folderLogic = FolderLogic();

  @override
  void dispose() {
    _folderLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(folderLogic: _folderLogic),
      SearchPage(folderLogic: _folderLogic),
      const ClusterPage(),
      SettingsPage(folderLogic: _folderLogic),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 2. SAFE CHECK: Decide layout based on screen width instead of Operating System
        if (constraints.maxWidth < 600) {
          return MobileLayout(
            currentIndex: _currentIndex,
            onIndexChanged: (index) => setState(() => _currentIndex = index),
            pages: pages,
          );
        } else {
          return DesktopLayout(
            currentIndex: _currentIndex,
            onIndexChanged: (index) => setState(() => _currentIndex = index),
            pages: pages,
          );
        }
      },
    );
  }
}
