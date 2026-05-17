import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:leran/ui/styling/theme_palette.dart';
import 'package:leran/ui/styling/layout_manager.dart';
import 'package:leran/logic/theme_logic.dart';
import 'package:leran/logic/daemon_logic.dart';
import 'package:leran/logic/folder_logic.dart'; // Added
import 'package:leran/logic/sync_logic.dart'; // Added

final daemonManager = DaemonManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Start the Syncthing Daemon (Generates the dynamic API Key)
  await daemonManager.startDaemon();

  // 2. Initialize Logic Classes
  final themeLogic = ThemeLogic();
  final folderLogic = FolderLogic();
  final syncLogic = SyncLogic();

  // 3. Connect the Daemon's API key to the SyncLogic
  // This allows the UI to talk to the engine we just started
  if (daemonManager.currentApiKey != null) {
    syncLogic.updateSessionKey(daemonManager.currentApiKey!);
  }

  // Initialize SQLite for desktop
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 4. Desktop Window Setup
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
      windowManager.setPreventClose(false);
    });
  }

  await themeLogic.loadSettings();

  // 5. Start the app and pass all logic down
  runApp(
    LeranApp(
      themeLogic: themeLogic,
      folderLogic: folderLogic,
      syncLogic: syncLogic,
    ),
  );
}

class LeranApp extends StatelessWidget {
  final ThemeLogic themeLogic;
  final FolderLogic folderLogic;
  final SyncLogic syncLogic;

  const LeranApp({
    super.key,
    required this.themeLogic,
    required this.folderLogic,
    required this.syncLogic,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeLogic,
      builder: (context, _) {
        return MaterialApp(
          title: 'Leran',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(themeLogic.primaryColor),
          darkTheme: AppTheme.getDarkTheme(themeLogic.primaryColor),
          themeMode: themeLogic.themeMode,
          // LayoutManager now receives the Logic instances to distribute to pages
          home: LayoutManager(
            themeLogic: themeLogic,
            folderLogic: folderLogic,
            syncLogic: syncLogic,
          ),
        );
      },
    );
  }
}
