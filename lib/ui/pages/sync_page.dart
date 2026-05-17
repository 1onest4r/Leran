import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../logic/sync_logic.dart';
import '../../logic/folder_logic.dart';

class SyncPage extends StatefulWidget {
  final SyncLogic syncLogic;
  final FolderLogic folderLogic;

  const SyncPage({
    super.key,
    required this.syncLogic,
    required this.folderLogic,
  });

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _peerIdController = TextEditingController();
  String _selectedSyncType = 'sendreceive';

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.syncLogic.apiKey;
    widget.syncLogic.checkStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _peerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DEVICE SYNC',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: widget.syncLogic,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildEngineStatusCard(), // The new status-only card
              const SizedBox(height: 20),

              // Only show the rest if the engine is actually connected
              if (widget.syncLogic.isOnline) ...[
                _buildLocalStatusCard(),
                const SizedBox(height: 20),
                _buildPendingRequestsCard(),
                const SizedBox(height: 20),
                _buildAddPeerCard(),
              ] else ...[
                // Show a helpful tip if still offline after a few seconds
                _buildTroubleshootingTip(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSetupCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Connect to Local Daemon",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Find your API key in Syncthing GUI > Actions > Settings > General",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: "Syncthing API Key",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.syncLogic.saveApiKey(_apiKeyController.text);
                  },
                  child: const Text("Save & Connect"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  widget.syncLogic.isOnline ? Icons.check_circle : Icons.error,
                  color: widget.syncLogic.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.syncLogic.isOnline
                      ? "Daemon Connected"
                      : "Daemon Offline",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.syncLogic.isFetching)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "2. Your Device Identity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SelectableText(
              widget.syncLogic.localDeviceId,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text("Copy My ID"),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: widget.syncLogic.localDeviceId),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Device ID copied!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPeerCard() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "3. Connect a Peer & Set Data Flow",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Choose how data should move between this device and the remote device.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Data Flow Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSyncType,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: const [
                    DropdownMenuItem(
                      value: 'sendreceive',
                      child: Row(
                        children: [
                          Icon(Icons.sync, color: Colors.blue),
                          SizedBox(width: 10),
                          Text("Two-Way Sync (Send & Receive)"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'sendonly',
                      child: Row(
                        children: [
                          Icon(Icons.upload, color: Colors.orange),
                          SizedBox(width: 10),
                          Text("Send Only (Backup to remote)"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'receiveonly',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.green),
                          SizedBox(width: 10),
                          Text("Receive Only (Download from remote)"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSyncType = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _peerIdController,
                    decoration: const InputDecoration(
                      labelText: "Remote Device ID",
                      hintText: "Paste ID here...",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Share Folder"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onPressed: () async {
                    if (_peerIdController.text.isNotEmpty) {
                      if (widget.folderLogic.folderPath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Error: Open a folder in Leran first!",
                            ),
                          ),
                        );
                        return;
                      }

                      // Passing the selected sync type to the logic
                      String? errorMsg = await widget.syncLogic
                          .addDeviceAndShareFolder(
                            _peerIdController.text,
                            widget.folderLogic.folderPath,
                            _selectedSyncType, // <--- PASSED HERE
                          );

                      if (errorMsg != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        _peerIdController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Success! Sent to peer."),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsCard() {
    final pendingDevices = widget.syncLogic.pendingDevices;
    final pendingFolders = widget.syncLogic.pendingFolders;

    if (pendingDevices.isEmpty && pendingFolders.isEmpty) {
      return const SizedBox.shrink(); // Hide if nothing is pending
    }

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🔔 Incoming Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Pending Devices List
            ...pendingDevices.entries.map((entry) {
              String deviceId = entry.key;
              String deviceName = entry.value['name'] ?? 'Unknown Device';
              return ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.computer, color: Colors.blue),
                title: Text("Device Request: $deviceName"),
                subtitle: Text(
                  deviceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  onPressed: () =>
                      widget.syncLogic.acceptPendingDevice(deviceId),
                  child: const Text("Accept"),
                ),
              );
            }).toList(),

            if (pendingDevices.isNotEmpty && pendingFolders.isNotEmpty)
              const SizedBox(height: 12),

            // Pending Folders List
            ...pendingFolders.entries.map((entry) {
              String folderId = entry.key;
              String folderLabel = entry.value['label'] ?? 'Unknown Folder';

              // Extract the device ID that offered this folder
              Map offeredBy = entry.value['offeredBy'] ?? {};
              String remoteDeviceId = offeredBy.keys.isNotEmpty
                  ? offeredBy.keys.first
                  : '';

              return ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.folder_shared, color: Colors.orange),
                title: Text("Folder Request: $folderLabel"),
                subtitle: const Text("Requires a folder to be open in Leran"),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (widget.folderLogic.folderPath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Error: Open a folder in Leran to store these files!",
                          ),
                        ),
                      );
                      return;
                    }
                    widget.syncLogic.acceptPendingFolder(
                      folderId,
                      folderLabel,
                      remoteDeviceId,
                      widget.folderLogic.folderPath!,
                    );
                  },
                  child: const Text("Accept Folder"),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineStatusCard() {
    final isOnline = widget.syncLogic.isOnline;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      color: isOnline
          ? primaryColor.withOpacity(0.05)
          : Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isOnline ? primaryColor : Colors.red, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            isOnline
                ? Icon(Icons.bolt, color: primaryColor, size: 32)
                : const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? "Sync Engine Active" : "Initializing Engine...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isOnline ? primaryColor : Colors.red,
                    ),
                  ),
                  Text(
                    isOnline
                        ? "P2P network is ready for transfers."
                        : "Establishing secure local connection...",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTip() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: Text(
        "Tip: If the engine doesn't start within 10 seconds, try restarting the app. Ensure no other instances of Syncthing are running on your device.",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
