import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'services/settings_service.dart';
import 'ui/screens/home_page.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load your user settings
  await SettingsService().loadSettings();

  // 3. Initialize Window Manager for Desktop (Linux, Windows, macOS)
  await windowManager.ensureInitialized();

  // 4. Define Native Window Properties
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700), // Default size when app first opens
    minimumSize: Size(
      650,
      450,
    ), // THE FIX: Prevents squishing the app too small!
    center: true, // Open in the center of the screen
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Digital Garden',
  );

  // 5. Apply the properties and show the window
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 6. Run the Flutter UI
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService(),
      builder: (context, child) {
        final settings = SettingsService();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Digital Garden',
          theme: settings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          builder: (context, child) {
            // Apply text scaling globally
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(settings.uiScale)),
              child: child!,
            );
          },
          home: const HomePage(),
        );
      },
    );
  }
}
