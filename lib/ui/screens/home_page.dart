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

    // --- LAYOUT MATH ---
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxSidebarWidth = screenWidth * 0.4; // Max 40% of the window
    final double minSidebarWidth =
        50.0 * scale; // Width of the collapsed mini bar

    // Clamp constraints
    if (_dragWidth > maxSidebarWidth && maxSidebarWidth > 0) {
      _dragWidth = maxSidebarWidth;
    }
    if (_dragWidth < minSidebarWidth) {
      _dragWidth = minSidebarWidth;
    }

    // If width drops below 80, we switch to the collapsed UI mode
    final bool isCollapsed = _dragWidth <= 80.0 * scale;

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
                : Stack(
                    children: [
                      // 1. MAIN UI LAYER
                      Row(
                        children: [
                          // Left Sidebar (Always rendered now, just changes state)
                          SizedBox(
                            width: _dragWidth,
                            child: LeftSidebar(
                              isCollapsed: isCollapsed,
                              onToggleSidebar: _toggleSidebar,
                            ),
                          ),
                          // Native perfect divider (No gap!)
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

                      // 2. INVISIBLE DRAG SASH LAYER
                      Positioned(
                        left:
                            _dragWidth -
                            (4 * scale), // Center grab area over the line
                        top: 0,
                        bottom: 0,
                        width: 8 * scale, // Grab area
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
                              // Snap physics when user lets go
                              setState(() {
                                if (_dragWidth > minSidebarWidth &&
                                    _dragWidth <= 80 * scale) {
                                  _dragWidth = minSidebarWidth; // Snap shut
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
                                  duration: const Duration(milliseconds: 150),
                                  // Shows green line only when hovering
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
                  ),
          ),
        );
      },
    );
  }
}
