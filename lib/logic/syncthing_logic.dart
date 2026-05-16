import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncthingService {
  // By default, Syncthing's GUI/API runs on this local port
  final String baseUrl = 'http://127.0.0.1:8384/rest';

  // When we launch the binary later, we will force it to use this exact API key
  // so our app has exclusive, secure access to it.
  final String apiKey = 'leran-secure-api-key-2026';

  Map<String, String> get _headers => {
    'X-API-Key': apiKey,
    'Content-Type': 'application/json',
  };

  /// 1. Fetch this device's unique Syncthing ID
  Future<String?> getMyDeviceId() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/status'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['myID']; // Looks like "ABCD123-EFGH456-..."
      }
    } catch (e) {
      print("Syncthing is not running yet: $e");
    }
    return null;
  }

  /// 2. Add a new trusted device (peer)
  Future<bool> addDevice(String deviceId) async {
    try {
      // First, get current config
      final configRes = await http.get(
        Uri.parse('$baseUrl/config'),
        headers: _headers,
      );
      if (configRes.statusCode != 200) return false;

      final config = json.decode(configRes.body);

      // Check if device already exists
      List devices = config['devices'];
      bool exists = devices.any((d) => d['deviceID'] == deviceId);
      if (exists) return true;

      // Add the new device to the list
      devices.add({
        "deviceID": deviceId,
        "name": "Linked Device",
        "introducer": false,
      });

      config['devices'] = devices;

      // Post the updated config back to Syncthing
      final updateRes = await http.put(
        Uri.parse('$baseUrl/config'),
        headers: _headers,
        body: json.encode(config),
      );

      return updateRes.statusCode == 200;
    } catch (e) {
      print("Error adding device: $e");
      return false;
    }
  }

  /// 3. Tell Syncthing to share our Leran folder with the new device
  Future<bool> shareFolderWithDevice(String folderPath, String deviceId) async {
    try {
      final configRes = await http.get(
        Uri.parse('$baseUrl/config'),
        headers: _headers,
      );
      final config = json.decode(configRes.body);

      // Syncthing needs a unique ID for the folder across the network
      final String folderId = "leran-archive-main";

      List folders = config['folders'];
      var folder = folders.firstWhere(
        (f) => f['id'] == folderId,
        orElse: () => null,
      );

      if (folder == null) {
        // Create new folder config
        folder = {
          "id": folderId,
          "path": folderPath,
          "devices": [
            {"deviceID": config['myID']},
          ], // Start with just us
        };
        folders.add(folder);
      }

      // Add the target device to this folder
      List folderDevices = folder['devices'];
      if (!folderDevices.any((d) => d['deviceID'] == deviceId)) {
        folderDevices.add({"deviceID": deviceId});
      }

      final updateRes = await http.put(
        Uri.parse('$baseUrl/config'),
        headers: _headers,
        body: json.encode(config),
      );

      return updateRes.statusCode == 200;
    } catch (e) {
      print("Error sharing folder: $e");
      return false;
    }
  }
}
