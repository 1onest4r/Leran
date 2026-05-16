import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Needed for the Clipboard
import '../../logic/syncthing_logic.dart';
import '../../logic/folder_logic.dart';

class SyncPage extends StatefulWidget {
  final FolderLogic folderLogic;

  const SyncPage({super.key, required this.folderLogic});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final SyncthingService _syncService = SyncthingService();
  final TextEditingController _peerIdController = TextEditingController();

  String? _myDeviceId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyId();
  }

  Future<void> _fetchMyId() async {
    final id = await _syncService.getMyDeviceId();
    setState(() {
      _myDeviceId = id;
      _isLoading = false;
    });
  }

  Future<void> _connectToDevice() async {
    final peerId = _peerIdController.text.trim();
    if (peerId.isEmpty || widget.folderLogic.folderPath == null) return;

    setState(() => _isLoading = true);

    // 1. Trust the device
    bool deviceAdded = await _syncService.addDevice(peerId);

    // 2. Share our notes folder with them
    if (deviceAdded) {
      await _syncService.shareFolderWithDevice(
        widget.folderLogic.folderPath!,
        peerId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Device linked and folder shared!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      _peerIdController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to link device.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _copyToClipboard() {
    if (_myDeviceId != null) {
      Clipboard.setData(ClipboardData(text: _myDeviceId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Device ID copied to clipboard!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "NETWORK",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _myDeviceId == null
          ? _buildEngineOffline()
          : _buildSyncInterface(theme, primaryColor),
    );
  }

  Widget _buildEngineOffline() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.redAccent.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sync Engine Offline",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "The background daemon is not running yet.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncInterface(ThemeData theme, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // My Device ID Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Device ID",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Share this ID with your other devices to establish a secure, peer-to-peer connection.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // ID Display Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _myDeviceId!,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: _copyToClipboard,
                      tooltip: "Copy ID",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Link Device Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Link a Device",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter the ID of the device you want to sync with.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _peerIdController,
                decoration: const InputDecoration(
                  hintText: "Paste Device ID here...",
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: widget.folderLogic.folderPath == null
                      ? null
                      : _connectToDevice,
                  icon: const Icon(Icons.sync, color: Colors.black),
                  label: const Text(
                    "Connect & Sync Notes",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.folderLogic.folderPath == null)
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    "Please select a local folder in Settings first.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
