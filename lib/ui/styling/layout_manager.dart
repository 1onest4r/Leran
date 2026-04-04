import 'package:flutter/material.dart';
import 'dart:io';

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

  // This list maps your icons to the actual pages
  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ClusterPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //breakpoint 600px
        if (Platform.isAndroid || Platform.isIOS) {
          return MobileLayout(
            currentIndex: _currentIndex,
            onIndexChanged: (index) => setState(() => _currentIndex = index),
            pages: _pages,
          );
        } else {
          return DesktopLayout(
            currentIndex: _currentIndex,
            onIndexChanged: (index) => setState(() => _currentIndex = index),
            pages: _pages,
          );
        }
      },
    );
  }
}
