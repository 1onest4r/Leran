import 'dart:ui';
import 'package:flutter/material.dart';
import '../obsidian_theme.dart';
import '../mobile_editor_page.dart';

class MobileTagsView extends StatelessWidget {
  const MobileTagsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildTopHeader(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            const SizedBox(height: 12),
            // Sub Header Details mimicking Samsung logic structure
            Center(
              child: Text(
                "Organized",
                style: Obsidian.manrope.copyWith(
                  color: Obsidian.text,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "3 grouped spaces",
                style: TextStyle(color: Obsidian.textDim, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Responsive App-like Grid for grouped Folders!
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Uses ListView scroll
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildFolderBlock(
                  context,
                  title: "#design",
                  contents: [
                    "Philosophies",
                    "Color Theory",
                    "Tokens",
                    "Layout Grids",
                  ],
                ),
                _buildFolderBlock(
                  context,
                  title: "Ideas",
                  contents: ["Groceries", "Gift Ideas", "Project Emerald"],
                ),
                _buildFolderBlock(
                  context,
                  title: "Meeting Notes",
                  contents: ["Q4 Planning", "Dev sync"],
                ),
              ],
            ),
            const SizedBox(height: 100), // Buffer for navbar
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopHeader() {
    return AppBar(
      backgroundColor: Obsidian.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 24,
      title: Text(
        "SPACES",
        style: Obsidian.manrope.copyWith(
          color: Obsidian.emerald,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  // Looks exactly like iOS / Android grouping Folders but sized and styled to match Notes!
  Widget _buildFolderBlock(
    BuildContext context, {
    required String title,
    required List<String> contents,
  }) {
    return GestureDetector(
      onTap: () => _showFolderContentsDialog(context, title, contents),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Obsidian.surfaceLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              // Draw the inner tiny grid
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contents.length > 4
                    ? 4
                    : contents.length, // Preview max 4 tiny blocks
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Obsidian.surfaceHighest, // Nested elevation color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      contents[idx],
                      style: TextStyle(color: Obsidian.textDim, fontSize: 8),
                      overflow: TextOverflow.fade,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Opening the group expands a nice glassy BottomSheet previewing the items.
  void _showFolderContentsDialog(
    BuildContext context,
    String folderTitle,
    List<String> notesList,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Obsidian.surfaceLow.withOpacity(
                0.95,
              ), // Ghost shell base layer
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // shrinkwraps dynamic data sizes natively
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Obsidian.textDim.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Folder: $folderTitle",
                    style: Obsidian.manrope.copyWith(
                      color: Obsidian.text,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shows exact files to click
                  ...notesList.map(
                    (noteLabel) => GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MobileEditorPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Obsidian.surfaceHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          noteLabel,
                          style: TextStyle(
                            color: Obsidian.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
