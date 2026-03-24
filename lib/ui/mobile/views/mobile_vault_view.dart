import 'package:flutter/material.dart';
import '../obsidian_theme.dart';
import '../mobile_editor_page.dart';

class MobileVaultView extends StatelessWidget {
  const MobileVaultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Background pulled from the main wrapper
      appBar: _buildTopHeader(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 8),

            // Staggered Note Card logic mapping Design guidelines
            _buildNoteCard(
              context: context,
              date: "OCTOBER 24, 2023",
              title: "Philosophies of the Obsidian Interface",
              content:
                  "Design is not just what it looks like and feels like. Design is how it works. In the context of a dark mode archive, we must respect the void...",
              tags: ["#design", "#manifesto"],
              isPinned: true,
            ),
            _buildNoteCard(
              context: context,
              date: "2 HOURS AGO",
              title: "Weekly Reading List",
              content:
                  "1. The Design of Everyday Things\n2. Speculative Everything",
            ),
            _buildNoteCard(
              context: context,
              date: "YESTERDAY",
              title: "Project: Emerald",
              content:
                  "Finalizing the primary container tokens for the Material 3 implementation. Need to check accessibility ratios.",
            ),

            const SizedBox(
              height: 100,
            ), // Spacing buffer so FAB doesn't cover last note
          ],
        ),
      ),

      // Floating Action Button for New Notes
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MobileEditorPage()),
          );
        },
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: Obsidian.gemstoneGradient,
            boxShadow: [
              BoxShadow(
                color: Obsidian.emerald.withOpacity(0.3),
                blurRadius: 32,
                spreadRadius: 4,
                offset: const Offset(0, 8), // Ambient physical glow shadow
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Obsidian.emeraldDim, size: 32),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopHeader() {
    return AppBar(
      backgroundColor: Obsidian.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 24, // Matches margins strictly without Hamburger
      title: Text(
        "LERAN",
        style: Obsidian.manrope.copyWith(
          color: Obsidian.emerald,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
        // App Logo Placeholder (Ready for icon swap later)
        Container(
          height: 36,
          width: 36,
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Obsidian.surfaceHighest,
            shape: BoxShape.circle,
            border: Border.all(color: Obsidian.textDim.withOpacity(0.2)),
          ),
          child: const Icon(
            Icons.diamond_outlined,
            color: Obsidian.text,
            size: 20,
          ),
        ),
      ],
    );
  }

  // --- COMPONENT: Nested Obsidian Card (No Line Rule) ---
  Widget _buildNoteCard({
    required BuildContext context,
    required String date,
    required String title,
    required String content,
    List<String> tags = const [],
    bool isPinned = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Tapping opens the editor
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MobileEditorPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Obsidian.surfaceLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Obsidian.inter.copyWith(
                    color: Obsidian.textDim.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isPinned)
                  const Icon(Icons.push_pin, color: Obsidian.emerald, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Obsidian.inter.copyWith(
                color: Obsidian.textDim,
                height: 1.5,
                fontSize: 15,
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: tags
                    .map(
                      (t) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t == "#design"
                              ? Obsidian.emeraldDim.withOpacity(0.5)
                              : Obsidian.surfaceHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            color: t == "#design"
                                ? Obsidian.emeraldLight
                                : Obsidian.textDim,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
