import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../obsidian_theme.dart';
import '../mobile_editor_page.dart';
import '../../../logic/vault_controller.dart';
import '../../../services/file_service.dart';
import '../../../services/tag_service.dart';

class MobileVaultView extends StatelessWidget {
  const MobileVaultView({super.key});

  void _openNewNote(BuildContext context) {
    VaultController().activeFile = null;
    VaultController().fileContent = '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MobileEditorPage(file: null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vault = VaultController();

    return AnimatedBuilder(
      animation: vault,
      builder: (context, _) {
        final List<FileSystemEntity> notes = vault.sortedFiles;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildTopHeader(context),
          body: SafeArea(
            child: vault.selectedDirectory == null
                ? _buildMissingDirectoryState(context)
                : notes.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: notes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == notes.length) {
                        return const SizedBox(height: 120);
                      }
                      return DynamicNoteCard(
                        file: notes[index],
                        isPinned: vault.isPinned(notes[index].path),
                      );
                    },
                  ),
          ),
          floatingActionButton: vault.selectedDirectory == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 85),
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    onPressed: () => _openNewNote(context),
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
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_document,
                        color: Obsidian.emeraldDim,
                        size: 28,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildTopHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Obsidian.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 24,
      title: Text(
        'VAULT',
        style: Obsidian.manrope.copyWith(
          color: Obsidian.emerald,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Obsidian.emerald.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 56,
              color: Obsidian.emerald.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Archive is Empty',
            style: Obsidian.manrope.copyWith(
              color: Obsidian.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "It's silent in here. Begin by transcribing\nyour first thought into the void.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Obsidian.textDim.withOpacity(0.8),
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_note, size: 24),
            label: const Text(
              'Create First Note',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Obsidian.emerald,
              foregroundColor: Obsidian.background,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _openNewNote(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingDirectoryState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off_outlined,
              color: Obsidian.emerald.withOpacity(0.4),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Vault',
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select a folder on your device to serve as your digital archive. Your notes will be stored safely here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Obsidian.textDim, height: 1.5),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text(
                'Select Local Folder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Obsidian.emerald,
                side: const BorderSide(color: Obsidian.emerald, width: 2),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final path = await FilePicker.platform.getDirectoryPath();
                if (path != null) {
                  VaultController().setVaultDirectory(path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DynamicNoteCard — shows title, body preview, and tag chips
// =============================================================================

class DynamicNoteCard extends StatelessWidget {
  final FileSystemEntity file;
  final bool isPinned;

  const DynamicNoteCard({super.key, required this.file, this.isPinned = false});

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}'.toUpperCase();
  }

  String _titleFromFilename(String filename) {
    return filename
        .replaceAll(RegExp(r'\.md$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\.txt$', caseSensitive: false), '');
  }

  @override
  Widget build(BuildContext context) {
    final String filename = file.uri.pathSegments.last;
    final String title = _titleFromFilename(filename);
    final FileStat stat = file.statSync();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MobileEditorPage(file: file)),
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
            // Date stamp and Pin Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(stat.modified),
                  style: Obsidian.inter.copyWith(
                    color: Obsidian.textDim.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isPinned)
                  const Icon(Icons.push_pin, color: Obsidian.emerald, size: 14),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Body preview + tag chips — both driven by a single FutureBuilder
            FutureBuilder<String>(
              future: FileService.readFile(file),
              builder: (context, snapshot) {
                String previewText = 'Reading void...';
                List<String> tags = [];

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError || snapshot.data == null) {
                    previewText = 'Could not load content.';
                  } else {
                    final content = snapshot.data!;
                    tags = TagService.parseTags(content);

                    final int nlIndex = content.indexOf('\n');
                    final body = nlIndex != -1 && nlIndex + 1 < content.length
                        ? content.substring(nlIndex + 1).trim()
                        : '';

                    // Strip tag tokens from the preview so they don't repeat
                    final cleanBody = body
                        .replaceAll(RegExp(r'#[a-zA-Z][a-zA-Z0-9_\-]*'), '')
                        .trim();

                    previewText = cleanBody.isNotEmpty
                        ? cleanBody
                        : 'No additional text.';
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Body preview
                    Text(
                      previewText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Obsidian.inter.copyWith(
                        color: Obsidian.textDim,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),

                    // Tag chips — only shown when the note has tags
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Obsidian.emeraldDim.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Obsidian.emerald.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: Obsidian.inter.copyWith(
                                color: Obsidian.emeraldLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
