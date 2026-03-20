import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../logic/vault_controller.dart';
import '../../services/settings_service.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- RESIZE STATE ---
  double _dragWidth = 250.0;
  bool _isHoveringSash = false;

  Future<void> _pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      VaultController().setVaultDirectory(result);
    }
  }

  // --- TOGGLE LOGIC ---
  void _toggleSidebar() {
    final settings = SettingsService();
    final scale = settings.uiScale;
    setState(() {
      if (_dragWidth <= 80.0 * scale) {
        _dragWidth = 250.0 * scale; // Open it
      } else {
        _dragWidth = 50.0 * scale; // Collapse to mini bar
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final vault = VaultController();
    final double scale = settings.uiScale;

    return AnimatedBuilder(
      animation: Listenable.merge([settings, vault]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: settings.scaffoldColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ==========================================================
                // THE ULTIMATE CRASH-PROOF FIX (Virtual Canvas)
                // ==========================================================

                // 1. Define the absolute minimum safe dimensions for the UI
                final double minSafeWidth = 700.0 * scale;
                final double minSafeHeight = 450.0 * scale;

                // 2. Determine the actual size the UI will be rendered at.
                // If the window is large, fill it. If it's too small, lock to safe limits.
                final double renderWidth = constraints.maxWidth > minSafeWidth
                    ? constraints.maxWidth
                    : minSafeWidth;

                final double renderHeight =
                    constraints.maxHeight > minSafeHeight
                    ? constraints.maxHeight
                    : minSafeHeight;

                // 3. Sidebar Math (Based on the safe renderWidth)
                final double minSidebarWidth = 50.0 * scale;
                double maxSidebarWidth = renderWidth * 0.4; // Max 40%

                if (maxSidebarWidth < minSidebarWidth) {
                  maxSidebarWidth = minSidebarWidth;
                }

                if (_dragWidth > maxSidebarWidth) _dragWidth = maxSidebarWidth;
                if (_dragWidth < minSidebarWidth) _dragWidth = minSidebarWidth;

                final bool isCollapsed = _dragWidth <= 80.0 * scale;

                // 4. Build the Main UI Content
                Widget mainContent = vault.selectedDirectory == null
                    // --- NO VAULT STATE ---
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
                    // --- MAIN UI STATE ---
                    : Stack(
                        children: [
                          Row(
                            children: [
                              // Left Sidebar
                              SizedBox(
                                width: _dragWidth,
                                child: ClipRect(
                                  child: LeftSidebar(
                                    isCollapsed: isCollapsed,
                                    onToggleSidebar: _toggleSidebar,
                                  ),
                                ),
                              ),

                              // Divider
                              Container(
                                width: 1 * scale,
                                color: settings.dividerColor,
                              ),

                              // Right Editor
                              Expanded(
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

                          // --- DRAGGABLE SASH ---
                          Positioned(
                            left: _dragWidth - (4 * scale),
                            top: 0,
                            bottom: 0,
                            width: 8 * scale,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeLeftRight,
                              onEnter: (_) =>
                                  setState(() => _isHoveringSash = true),
                              onExit: (_) =>
                                  setState(() => _isHoveringSash = false),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onPanUpdate: (details) {
                                  setState(() {
                                    _dragWidth += details.delta.dx;
                                  });
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    if (_dragWidth > minSidebarWidth &&
                                        _dragWidth <= 80 * scale) {
                                      _dragWidth =
                                          minSidebarWidth; // Snap closed
                                    } else if (_dragWidth > 80 * scale &&
                                        _dragWidth < 150 * scale) {
                                      _dragWidth = 200 * scale; // Snap open
                                    }
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: _isHoveringSash ? (2 * scale) : 0,
                                      color: _isHoveringSash
                                          ? settings.accentColor
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );

                // 5. Wrap the UI in the 2D Scrollable Safety Net
                // If the window is perfectly fine, you won't even notice this is here.
                // If the user squishes the window to 200x200, the UI stays 700x450 and allows scrolling.
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics:
                      const ClampingScrollPhysics(), // Stops bounce effects on desktop
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: renderWidth,
                      height: renderHeight,
                      child: mainContent,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
