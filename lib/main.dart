import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'services/settings_service.dart';
import 'ui/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().loadSettings();

  // Initialize Window Manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(650, 450), // Kept as fallback
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Digital Garden',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // THE LINUX FIX: Explicitly enforce the minimum size AFTER the window is created
    await windowManager.setMinimumSize(const Size(650, 450));

    await windowManager.show();
    await windowManager.focus();
  });

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
