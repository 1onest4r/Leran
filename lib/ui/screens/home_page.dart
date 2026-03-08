import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../logic/vault_controller.dart';
import '../../services/settings_service.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';

/// UI LAYER: Main Layout Wrapper.
/// Decides whether to show the "Open Folder" screen, or the Sidebars.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      // Send the result to the Brain/Logic Layer
      VaultController().setVaultDirectory(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final vault = VaultController();

    // Rebuilds when Settings (Theme) OR VaultController (Open/Close Vault) change
    return AnimatedBuilder(
      animation: Listenable.merge([settings, vault]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: settings.scaffoldColor,
          body: SafeArea(
            child: vault.selectedDirectory == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: settings.dimTextColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Vault Open",
                          style: TextStyle(
                            color: settings.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Select a folder to start writing.",
                          style: TextStyle(color: settings.dimTextColor),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _pickFolder,
                          icon: const Icon(Icons.create_new_folder),
                          label: const Text("Open Folder"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: settings.accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      const Expanded(flex: 2, child: LeftSidebar()),
                      VerticalDivider(width: 1, color: settings.dividerColor),
                      Expanded(
                        flex: 6,
                        child: vault.activeFile == null
                            ? Center(
                                child: Text(
                                  "Select a file to edit",
                                  style: TextStyle(
                                    color: settings.dimTextColor,
                                  ),
                                ),
                              )
                            // By passing the path as a ValueKey, Flutter forces
                            // RightSidebar to cleanly rebuild when the active file changes!
                            : RightSidebar(
                                key: ValueKey(vault.activeFile!.path),
                              ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
