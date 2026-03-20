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
                // THE REAL FIX: Proper Responsive Clamping
                // (No OverflowBox, No disappearing footers!)
                // ==========================================================

                // 1. Define ideal widths
                final double minSidebarWidth = 50.0 * scale;
                double maxSidebarWidth = constraints.maxWidth * 0.4; // Max 40%

                // Failsafe: if window is extremely narrow, override the 40% rule
                if (maxSidebarWidth < minSidebarWidth) {
                  maxSidebarWidth = minSidebarWidth;
                }

                // 2. Clamp the drag width so it obeys our ideal rules
                if (_dragWidth > maxSidebarWidth) _dragWidth = maxSidebarWidth;
                if (_dragWidth < minSidebarWidth) _dragWidth = minSidebarWidth;

                // 3. Absolute Failsafe for Linux:
                // If the OS strictly forces the window to be tiny (e.g. 10px wide),
                // we prevent the layout math from overflowing.
                double finalSidebarWidth = _dragWidth;
                if (finalSidebarWidth > constraints.maxWidth) {
                  finalSidebarWidth = constraints.maxWidth;
                }

                final bool isCollapsed = finalSidebarWidth <= 80.0 * scale;

                return vault.selectedDirectory == null
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
                                width: finalSidebarWidth,
                                // ClipRect ensures inner widgets cleanly cut off if squished too hard
                                child: ClipRect(
                                  child: LeftSidebar(
                                    isCollapsed: isCollapsed,
                                    onToggleSidebar: _toggleSidebar,
                                  ),
                                ),
                              ),

                              // Divider (Only render if there is room for it)
                              if (constraints.maxWidth > finalSidebarWidth)
                                Container(
                                  width: 1 * scale,
                                  color: settings.dividerColor,
                                ),

                              // Right Editor (Only render if there is room for it)
                              if (constraints.maxWidth > finalSidebarWidth)
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
                          if (constraints.maxWidth > finalSidebarWidth)
                            Positioned(
                              left: finalSidebarWidth - (4 * scale),
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
                                        width: _isHoveringSash
                                            ? (2 * scale)
                                            : 0,
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
              },
            ),
          ),
        );
      },
    );
  }
}
