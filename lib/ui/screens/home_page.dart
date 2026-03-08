import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../logic/vault_controller.dart';
import '../../services/settings_service.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      VaultController().setVaultDirectory(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final vault = VaultController();

    // The scale globally multiples UI padding constants to actually zoom application constraints
    final double scale = settings.uiScale;

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
                          size: 80 * scale,
                          color: settings.dimTextColor,
                        ),
                        SizedBox(height: 20 * scale),
                        Text(
                          "No Vault Open",
                          style: TextStyle(
                            color: settings.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          "Select a folder to start writing.",
                          style: TextStyle(color: settings.dimTextColor),
                        ),
                        SizedBox(height: 30 * scale),
                        ElevatedButton.icon(
                          onPressed: _pickFolder,
                          icon: const Icon(Icons.create_new_folder),
                          label: const Text("Open Folder"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: settings.accentColor,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24 * scale,
                              vertical: 16 * scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      const Expanded(flex: 2, child: LeftSidebar()),
                      VerticalDivider(
                        width: 1 * scale,
                        color: settings.dividerColor,
                      ),
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
