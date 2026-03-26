import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../obsidian_theme.dart';
import '../mobile_editor_page.dart';
import '../../../logic/vault_controller.dart';
import '../../../services/settings_service.dart';

class MobileTagsView extends StatefulWidget {
  const MobileTagsView({super.key});

  @override
  State<MobileTagsView> createState() => _MobileTagsViewState();
}

class _MobileTagsViewState extends State<MobileTagsView> {
  // tag -> list of file paths
  Map<String, List<String>> _tagGroups = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTagGroups();
    // Rebuild whenever vault changes (new notes saved, tags edited)
    VaultController().addListener(_loadTagGroups);
  }

  @override
  void dispose() {
    VaultController().removeListener(_loadTagGroups);
    super.dispose();
  }

  Future<void> _loadTagGroups() async {
    final groups = await VaultController().getAllTagGroups();
    if (mounted) {
      setState(() {
        _tagGroups = groups;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildTopHeader(),
          body: SafeArea(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Obsidian.emerald),
                  )
                : _tagGroups.isEmpty
                ? _buildEmptyState()
                : _buildTagList(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildTopHeader() {
    return AppBar(
      backgroundColor: Obsidian.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 24,
      title: Text(
        'SPACES',
        style: Obsidian.manrope.copyWith(
          color: Obsidian.emerald,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildTagList() {
    final tags = _tagGroups.keys.toList();
    final totalNotes = _tagGroups.values
        .map((v) => v.length)
        .fold(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Containers',
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
            '${tags.length} tag${tags.length == 1 ? '' : 's'} · $totalNotes note${totalNotes == 1 ? '' : 's'}',
            style: TextStyle(color: Obsidian.textDim, fontSize: 14),
          ),
        ),
        const SizedBox(height: 32),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tags.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final tag = tags[index];
            final paths = _tagGroups[tag]!;
            return _TagGroupCard(
              tag: tag,
              filePaths: paths,
              onTap: () => _showTagNotesSheet(tag, paths),
            );
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sell_outlined,
              color: Obsidian.emerald.withOpacity(0.4),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'No Tags Yet',
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Open a note, tap the menu button, and add tags to start organising your archive into spaces.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Obsidian.textDim,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagNotesSheet(String tag, List<String> paths) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Obsidian.surfaceLow.withOpacity(0.97),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Obsidian.textDim.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Obsidian.emeraldDim.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Obsidian.emerald.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: Obsidian.manrope.copyWith(
                                  color: Obsidian.emeraldLight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${paths.length} note${paths.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Obsidian.textDim,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: paths.length,
                          itemBuilder: (context, i) {
                            final path = paths[i];
                            final vault = VaultController();
                            final title = vault.titleFromPath(path);
                            final file = vault.files.firstWhere(
                              (f) => f.path == path,
                              orElse: () => File(path),
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MobileEditorPage(file: file),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Obsidian.surfaceHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Obsidian.textDim,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: Obsidian.manrope.copyWith(
                                          color: Obsidian.text,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Obsidian.textDim,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Tag group card shown in the 2-column grid
// =============================================================================

class _TagGroupCard extends StatelessWidget {
  final String tag;
  final List<String> filePaths;
  final VoidCallback onTap;

  const _TagGroupCard({
    required this.tag,
    required this.filePaths,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vault = VaultController();
    // Show up to 4 note titles as preview tiles inside the card
    final previewTitles = filePaths
        .take(4)
        .map((p) => vault.titleFromPath(p))
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Obsidian.surfaceLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag label
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#$tag',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Obsidian.manrope.copyWith(
                      color: Obsidian.emeraldLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Obsidian.emeraldDim.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${filePaths.length}',
                    style: Obsidian.inter.copyWith(
                      color: Obsidian.emerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Mini note preview grid
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previewTitles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Obsidian.surfaceHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      previewTitles[idx],
                      style: TextStyle(color: Obsidian.textDim, fontSize: 8),
                      overflow: TextOverflow.fade,
                      maxLines: 3,
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
}
