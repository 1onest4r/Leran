import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:leran/ui/styling/theme_palette.dart';
import 'package:leran/ui/styling/layout_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 100% Web-Safe Platform Check (No dart:io needed!)
  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        size: Size(1280, 720),
        minimumSize: Size(360, 500),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: "leran",
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  runApp(const LeranApp());
}

class LeranApp extends StatelessWidget {
  const LeranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const LayoutManager(),
    );
  }
}
