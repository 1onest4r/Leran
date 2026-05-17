import 'package:flutter/material.dart';
import 'package:leran/logic/folder_logic.dart';
import 'package:leran/logic/theme_logic.dart';
import 'package:leran/logic/sync_logic.dart';
import 'dart:io';

import '../pages/cluster_page.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';
import '../pages/sync_page.dart';
import 'desktop_layout.dart';
import 'mobile_layout.dart';

class LayoutManager extends StatefulWidget {
  final ThemeLogic themeLogic;
  final FolderLogic folderLogic;
  final SyncLogic syncLogic;
  const LayoutManager({
    super.key,
    required this.themeLogic,
    required this.folderLogic,
    required this.syncLogic,
  });

  @override
  State<LayoutManager> createState() => _LayoutManagerState();
}

class _LayoutManagerState extends State<LayoutManager> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // These pages now use the logic instances passed down from the root of the app
    final List<Widget> pages = [
      HomePage(folderLogic: widget.folderLogic),
      SearchPage(folderLogic: widget.folderLogic),
      ClusterPage(folderLogic: widget.folderLogic),
      SyncPage(syncLogic: widget.syncLogic, folderLogic: widget.folderLogic),
      SettingsPage(
        folderLogic: widget.folderLogic,
        themeLogic: widget.themeLogic,
      ),
    ];

    // Platform detection for UI switching
    if (Platform.isAndroid || Platform.isIOS) {
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
  }
}
