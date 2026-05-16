import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SyncLogic extends ChangeNotifier {
  String apiUrl = 'http://127.0.0.1:8384/rest';
  String apiKey = ''; // Syncthing requires an API key for security

  String localDeviceId = 'Not connected';
  bool isOnline = false;
  bool isFetching = false;

  Map<String, dynamic> pendingDevices = {};
  Map<String, dynamic> pendingFolders = {};
  Timer? _pollingTimer;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  SyncLogic() {
    _loadSettings();
  }

  Future<void> checkStatus() async {
    if (apiKey.isEmpty) return;

    isFetching = true;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse('$apiUrl/system/status'),
            headers: {'X-API-Key': apiKey},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        localDeviceId = data['myID'];
        isOnline = true;
      } else {
        isOnline = false;
      }
    } catch (e) {
      print("Syncthing API Error: $e");
      isOnline = false;
    }

    isFetching = false;
    notifyListeners();
  }

  Future<void> fetchPendingRequests() async {
    if (!isOnline) return;

    try {
      // Fetch Pending Devices
      final devRes = await http.get(
        Uri.parse('$apiUrl/cluster/pending/devices'),
        headers: {'X-API-Key': apiKey},
      );
      if (devRes.statusCode == 200) {
        pendingDevices = jsonDecode(devRes.body);
      }

      // Fetch Pending Folders
      final folRes = await http.get(
        Uri.parse('$apiUrl/cluster/pending/folders'),
        headers: {'X-API-Key': apiKey},
      );
      if (folRes.statusCode == 200) {
        pendingFolders = jsonDecode(folRes.body);
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching pending: $e");
    }
  }

  Future<void> acceptPendingDevice(String deviceId) async {
    try {
      final configRes = await http.get(
        Uri.parse('$apiUrl/config'),
        headers: {'X-API-Key': apiKey},
      );
      if (configRes.statusCode == 200) {
        final config = jsonDecode(configRes.body);

        List devices = config['devices'];
        if (!devices.any((d) => d['deviceID'] == deviceId)) {
          devices.add({"deviceID": deviceId});
          config['devices'] = devices;

          await http.put(
            Uri.parse('$apiUrl/config'),
            headers: {'X-API-Key': apiKey, 'Content-Type': 'application/json'},
            body: jsonEncode(config),
          );

          await http.delete(
            Uri.parse('$apiUrl/cluster/pending/devices/$deviceId'),
            headers: {'X-API-Key': apiKey},
          );
          fetchPendingRequests();
        }
      }
    } catch (e) {
      print("Error accepting device: $e");
    }
  }

  Future<void> acceptPendingFolder(
    String folderId,
    String folderLabel,
    String remoteDeviceId,
    String localPath,
  ) async {
    try {
      final configRes = await http.get(
        Uri.parse('$apiUrl/config'),
        headers: {'X-API-Key': apiKey},
      );
      if (configRes.statusCode == 200) {
        final config = jsonDecode(configRes.body);
        List folders = config['folders'];

        if (!folders.any((f) => f['id'] == folderId)) {
          folders.add({
            "id": folderId,
            "label": folderLabel,
            "path": localPath.replaceAll('\\', '/'),
            "devices": [
              {"deviceID": localDeviceId},
              {"deviceID": remoteDeviceId},
            ],
          });
          config['folders'] = folders;

          await http.put(
            Uri.parse('$apiUrl/config'),
            headers: {'X-API-Key': apiKey, 'Content-Type': 'application/json'},
            body: jsonEncode(config),
          );

          await http.delete(
            Uri.parse('$apiUrl/cluster/pending/folders/$folderId'),
            headers: {'X-API-Key': apiKey},
          );
          fetchPendingRequests();
        }
      }
    } catch (e) {
      print("Error accepting folder: $e");
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('syncthing_api_key') ?? '';
    if (apiKey.isNotEmpty) {
      checkStatus();
    }
  }

  Future<void> saveApiKey(String newKey) async {
    apiKey = newKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('syncthing_api_key', apiKey);
    notifyListeners();
    checkStatus();
  }

  // 2. Add a remote device (Peer) to connect to
  Future<void> addDevice(String remoteDeviceId) async {
    if (!isOnline) return;

    try {
      // First, fetch the current config
      final configRes = await http.get(
        Uri.parse('$apiUrl/config'),
        headers: {'X-API-Key': apiKey},
      );

      if (configRes.statusCode == 200) {
        final config = jsonDecode(configRes.body);

        // Add the new device to the devices list
        List devices = config['devices'];
        bool exists = devices.any((d) => d['deviceID'] == remoteDeviceId);

        if (!exists) {
          devices.add({"deviceID": remoteDeviceId});
          config['devices'] = devices;

          // Post the updated config back to Syncthing
          await http.post(
            Uri.parse('$apiUrl/config'),
            headers: {'X-API-Key': apiKey, 'Content-Type': 'application/json'},
            body: jsonEncode(config),
          );

          print("Device added successfully!");
        }
      }
    } catch (e) {
      print("Error adding device: $e");
    }
  }

  // 2. Add a remote device AND share the current workspace
  // 2. Add a remote device AND share the current workspace
  Future<String?> addDeviceAndShareFolder(
    String remoteDeviceId,
    String? folderPath,
  ) async {
    if (!isOnline) return "Error: Not connected to local daemon.";
    if (folderPath == null || folderPath.isEmpty)
      return "Error: No folder selected in Leran.";

    remoteDeviceId = remoteDeviceId.trim();

    try {
      // 1. GET from the correct modern endpoint (/rest/config)
      final configRes = await http.get(
        Uri.parse('$apiUrl/config'),
        headers: {'X-API-Key': apiKey},
      );

      if (configRes.statusCode != 200) {
        return "Failed to read config: ${configRes.body}";
      }

      final config = jsonDecode(configRes.body);

      List devices = config['devices'];
      if (!devices.any((d) => d['deviceID'] == remoteDeviceId)) {
        devices.add({"deviceID": remoteDeviceId});
      }

      List folders = config['folders'];
      String folderId = "leran-workspace";
      int folderIndex = folders.indexWhere((f) => f['id'] == folderId);

      String safePath = folderPath.replaceAll('\\', '/');

      if (folderIndex == -1) {
        folders.add({
          "id": folderId,
          "label": "Leran Notes",
          "path": safePath,
          "type": "sendreceive",
          "devices": [
            {"deviceID": localDeviceId},
            {"deviceID": remoteDeviceId},
          ],
        });
      } else {
        List folderDevices = folders[folderIndex]['devices'];
        if (!folderDevices.any((d) => d['deviceID'] == remoteDeviceId)) {
          folderDevices.add({"deviceID": remoteDeviceId});
        }
        folders[folderIndex]['path'] = safePath;
      }

      config['devices'] = devices;
      config['folders'] = folders;

      // 2. PUT to the correct modern endpoint (/rest/config)
      final putRes = await http.put(
        Uri.parse('$apiUrl/config'),
        headers: {'X-API-Key': apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode(config),
      );

      if (putRes.statusCode != 200) {
        return "Syncthing Rejected Config: ${putRes.body}";
      }

      return null; // Null means Success!
    } catch (e) {
      return "Network Exception: $e";
    }
  }
}
