import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DaemonManager {
  Process? _process;
  String? currentApiKey;

  // 1. Generate a secure random API key for this session
  String _generateRandomKey() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(
      32,
      (index) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  String _getBinaryName() {
    if (Platform.isWindows) return 'syncthing-windows.exe';
    if (Platform.isLinux) return 'syncthing-linux';
    if (Platform.isAndroid) return 'syncthing-android'; // requires arm64 binary
    throw UnsupportedError('Operating System not supported for Daemon');
  }

  Future<void> startDaemon() async {
    String exeName = _getBinaryName();

    // 1. Kill old instances
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/F', '/IM', exeName]);
    } else if (Platform.isLinux) {
      await Process.run('killall', [exeName]);
    }

    // 2. WAIT for the OS to release the port (8389)
    await Future.delayed(const Duration(seconds: 1));

    if (_process != null) return;

    currentApiKey = _generateRandomKey();
    final supportDir = await getApplicationSupportDirectory();
    final localPath = join(supportDir.path, exeName);
    final configDirPath = join(supportDir.path, 'leran_sync_config');

    if (!await File(localPath).exists()) {
      try {
        final data = await rootBundle.load('bin/$exeName');
        final bytes = data.buffer.asUint8List();
        await File(localPath).writeAsBytes(bytes);

        if (!Platform.isWindows) {
          // On real Android, we need to be very aggressive with permissions
          await Process.run('chmod', ['755', localPath]);
        }
      } catch (e) {
        print("Extraction Error: $e");
        return;
      }
    }

    try {
      _process = await Process.start(localPath, [
        '--no-browser',
        '--no-restart',
        '--home=$configDirPath',
        '--gui-address=127.0.0.1:8389',
        '--gui-apikey=$currentApiKey',
      ]);

      _process!.stdout
          .transform(utf8.decoder)
          .listen((data) => print("SYNC LOG: $data"));
      _process!.stderr.transform(utf8.decoder).listen((data) {
        print("SYNC ENGINE ERROR: $data");
      });

      _process!.exitCode.then((code) {
        print("SYNCTHING DIED. Code: $code");
        _process = null;
      });

      print("Daemon started with PID: ${_process!.pid}");
    } catch (e) {
      print("CRITICAL: Failed to start Syncthing on Android.");
      print("Error Detail: $e");

      // If you get 'Permission Denied' here on Android 10+,
      // it's because of the W^X security restriction.
    }
  }

  void stopDaemon() {
    _process?.kill();
    _process = null;
    currentApiKey = null;
    print("Syncthing Daemon stopped.");
  }
}
