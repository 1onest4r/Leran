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
        title: const Text('Syncthing Control Panel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: widget.syncLogic,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildSetupCard(),
              const SizedBox(height: 20),
              if (widget.syncLogic.isOnline) ...[
                _buildLocalStatusCard(),
                const SizedBox(height: 20),
                _buildPendingRequestsCard(),
                const SizedBox(height: 20),
                _buildAddPeerCard(),
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "3. Connect a Peer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Paste another device's ID here to establish a connection.",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _peerIdController,
                    decoration: const InputDecoration(
                      labelText: "Remote Device ID",
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // --- THIS IS THE UPDATED BUTTON ---
                ElevatedButton(
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

                      // Wait for the logic to finish and catch any errors
                      String? errorMsg = await widget.syncLogic
                          .addDeviceAndShareFolder(
                            _peerIdController.text,
                            widget.folderLogic.folderPath,
                          );

                      // Check if it failed or succeeded
                      if (errorMsg != null) {
                        // FAILED: Show a RED SnackBar with the exact error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: Colors.red,
                            duration: const Duration(
                              seconds: 5,
                            ), // Keep it up longer to read it
                          ),
                        );
                      } else {
                        // SUCCESS: Show a GREEN SnackBar
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
                  child: const Text("Add Device & Share"),
                ),

                // ----------------------------------
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
}
