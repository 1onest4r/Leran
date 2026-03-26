import 'dart:io'; // Needed for Platform.isWindows, etc.
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'services/settings_service.dart';
import 'ui/responsive_layout.dart'; // The router we created earlier

void main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ONLY run window_manager on Desktop platforms!
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 600),
      minimumSize: Size(700, 450), // Your safe min-width logic
      center: true,
      titleBarStyle:
          TitleBarStyle.hidden, // Or normal depending on your preference
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 3. Load your global settings before app starts
  await SettingsService().loadSettings();

  // 4. Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo Vault',
          theme: ThemeData(
            useMaterial3: true,
            brightness: settings.isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
          // Route straight to our responsive router
          home: ResponsiveLayout(),
        );
      },
    );
  }
}
