import 'dart:ui';
import 'package:flutter/material.dart';
import 'obsidian_theme.dart';

class MobileEditorPage extends StatelessWidget {
  const MobileEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Obsidian.background,
      appBar: AppBar(
        backgroundColor: Obsidian.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Obsidian.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Philosophies of the...", // Demo truncated per html design
          style: Obsidian.manrope.copyWith(
            color: Obsidian.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Obsidian.textDim),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Obsidian.textDim),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.push_pin, color: Obsidian.emerald),
            onPressed: () {},
          ), // Filled state pinned
        ],
      ),
      body: Stack(
        children: [
          // Typing / Workspace layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "EDITED · OCT 24, 10:42 AM",
                    style: TextStyle(
                      color: Obsidian.textDim,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    cursorColor: Obsidian.emerald, // Mandatory from specs
                    style: Obsidian.manrope.copyWith(
                      color: Obsidian.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Note Title",
                    ),
                    controller: TextEditingController(
                      text: "The Obsidian Methodology",
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      cursorColor: Obsidian.emerald,
                      style: Obsidian.inter.copyWith(
                        color: Obsidian.text,
                        fontSize: 18,
                        height: 1.6,
                      ), // Line height spec prioritized
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            "Start transcribing your thoughts into the void...",
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                      controller: TextEditingController(
                        text:
                            "In the deep charcoal of the interface, the mind finds focus. Unlike the standard white canvas that aggressively reflects light, the Digital Obsidian absorbs distractions.\n\nKey principles:\n1. Tonal depth over borders.\n2. Emerald vitality.\n3. Editorial precision.",
                      ),
                    ),
                  ),
                  const SizedBox(height: 90), // Spacing for floating board
                ],
              ),
            ),
          ),

          // Layer 2: Formatter / Editor tools floating block (Backdrop 70%)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    color: Obsidian.surfaceHighest.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _formatTool(Icons.format_bold),
                            _formatTool(Icons.format_italic),
                            _formatTool(Icons.format_list_bulleted),
                            _formatTool(Icons.image_outlined),
                          ],
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: Obsidian.textDim.withOpacity(0.2),
                        ),
                        Row(
                          children: [
                            _formatTool(Icons.palette_outlined),
                            _formatTool(Icons.more_vert),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatTool(IconData icon) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: Obsidian.text, size: 22),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      splashRadius: 20,
    );
  }
}
