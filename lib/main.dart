import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:leran/ui/styling/theme_palette.dart';
import 'package:leran/ui/styling/layout_manager.dart';
import 'package:leran/logic/theme_logic.dart';

void main() async {
  // 1. Mandatory: Ensures Flutter is ready before we talk to the OS
  WidgetsFlutterBinding.ensureInitialized();

  // initialize SQLite FFI for desktop
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Check for Desktop (Linux/Windows/Mac)
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Initialize the window manager
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720), // The default size when the app opens
      minimumSize: Size(
        360,
        500,
      ), // THE HARD LOCK: User cannot shrink smaller than this
      center: true, // Opens the app in the middle of the screen
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: "leran", // Your App Name
    );

    // 3. Wait until the window is ready, then show it
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final themeLogic = ThemeLogic();
  await themeLogic.loadSettings();

  // 4. Finally, start the app (This runs on both Android and Linux)
  runApp(LeranApp(themeLogic: themeLogic));
}

class LeranApp extends StatelessWidget {
  final ThemeLogic themeLogic;
  const LeranApp({super.key, required this.themeLogic});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder forces the whole app to redraw instantly when theme changes!
    return ListenableBuilder(
      listenable: themeLogic,
      builder: (context, _) {
        return MaterialApp(
          title: 'Leran',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.getLightTheme(themeLogic.primaryColor),
          darkTheme: AppTheme.getDarkTheme(themeLogic.primaryColor),
          themeMode: themeLogic.themeMode,

          home: LayoutManager(themeLogic: themeLogic),
        );
      },
    );
  }
}
