import 'package:flutter/material.dart';
import 'services/settings_service.dart';
import 'ui/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Settings Service before the app starts
  await SettingsService().loadSettings();

  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to SettingsService here so the whole app rebuilds
    // if Dark Mode or UI Scale changes.
    return AnimatedBuilder(
      animation: SettingsService(),
      builder: (context, child) {
        final settings = SettingsService();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Digital Garden',
          theme: settings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          // Applies global UI scaling based on user settings
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
