import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:leran/ui/styling/theme_palette.dart';
import 'package:leran/ui/styling/layout_manager.dart';

void main() async {
  // 1. Mandatory: Ensures Flutter is ready before we talk to the OS
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Check for Desktop (Linux/Windows/Mac)
  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
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

  // 4. Finally, start the app (This runs on both Android and Linux)
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
