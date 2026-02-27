import 'package:flutter/material.dart';
import 'services/settings_service.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().loadSettings();
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
          // NEW: Apply UI Scaling Globally
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
