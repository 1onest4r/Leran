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
        // Theme is mostly handled manually in widgets via SettingsService,
        // but we set the baseline here.
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Digital Garden',
          theme: SettingsService().isDarkMode
              ? ThemeData.dark()
              : ThemeData.light(),
          home: const HomePage(),
        );
      },
    );
  }
}
