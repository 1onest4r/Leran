import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DaemonManager {
  Process? _process;

  Future<void> startDaemon() async {
    final supportDir = await getApplicationSupportDirectory();
    String exeName = Platform.isWindows ? 'syncthing.exe' : 'syncthing';
    final localPath = join(supportDir.path, exeName);

    // 1. Extract the binary from assets to local storage if it doesn't exist
    if (!await File(localPath).exists()) {
      final data = await rootBundle.load('bin/$exeName');
      final bytes = data.buffer.asUint8List();
      await File(localPath).writeAsBytes(bytes);

      // On Linux, we must make the file executable
      if (Platform.isLinux) {
        await Process.run('chmod', ['+x', localPath]);
      }
    }

    // 2. Launch Syncthing silently
    // --no-browser: Don't open the web tab
    // --no-restart: If it crashes, let our app handle it
    _process = await Process.start(localPath, [
      '--no-browser',
      '--no-restart',
    ], runInShell: Platform.isWindows);

    print("Syncthing Daemon started with PID: ${_process!.pid}");

    // Handle process output for debugging (optional)
    _process!.stdout.transform(SystemEncoding().decoder).listen((data) {
      // You can parse this log to find the API key automatically later!
      if (data.contains("API key is")) {
        print("LOG: $data");
      }
    });
  }

  void stopDaemon() {
    _process?.kill();
    _process = null;
  }
}
