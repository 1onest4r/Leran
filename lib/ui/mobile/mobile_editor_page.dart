import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'obsidian_theme.dart';
import '../../logic/vault_controller.dart';
import '../../services/settings_service.dart';
import '../../services/file_service.dart';
import '../../services/tag_service.dart';

class MobileEditorPage extends StatefulWidget {
  final FileSystemEntity? file;

  const MobileEditorPage({super.key, this.file});

  @override
  State<MobileEditorPage> createState() => _MobileEditorPageState();
}

class _MobileEditorPageState extends State<MobileEditorPage> {
  final VaultController _vault = VaultController();
  final SettingsService _settings = SettingsService();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late FocusNode _bodyFocusNode;
  late ScrollController _scrollController;

  bool _isLoading = true;
  bool _isDeleted = false;
  bool _isPinned = false;
  String? _originalFilename;

  // Live list of tags derived from the current body content
  List<String> _currentTags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _bodyFocusNode = FocusNode();
    _scrollController = ScrollController();
    _initializeEditor();
  }

  Future<void> _initializeEditor() async {
    if (widget.file != null) {
      _originalFilename = widget.file!.uri.pathSegments.last;
      _isPinned = _vault.isPinned(widget.file!.path);
      await _vault.openFile(widget.file!);
      final content = _vault.fileContent;

      final int nlIndex = content.indexOf('\n');
      if (content.isEmpty) {
        _titleController.text = _cleanTitle(_originalFilename!);
      } else if (nlIndex == -1) {
        _titleController.text = content.trim();
        _bodyController.text = '';
      } else {
        _titleController.text = content.substring(0, nlIndex).trim();
        _bodyController.text = content.substring(nlIndex + 1);
      }
    } else {
      _vault.activeFile = null;
      _vault.fileContent = '';
    }

    _refreshTags();
    if (mounted) setState(() => _isLoading = false);
  }

  // --- Tag helpers -----------------------------------------------------------

  void _refreshTags() {
    _currentTags = TagService.parseTags(_bodyController.text);
  }

  void _addTag(String tag) {
    final updated = TagService.addTag(_bodyController.text, tag);
    _bodyController.text = updated;
    _onContentChanged('');
    setState(_refreshTags);
  }

  void _removeTag(String tag) {
    final updated = TagService.removeTag(_bodyController.text, tag);
    _bodyController.text = updated;
    _onContentChanged('');
    setState(_refreshTags);
  }

  // --- Save / Exit -----------------------------------------------------------

  String _cleanTitle(String raw) {
    return raw
        .replaceAll(RegExp(r'\.md$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\.txt$', caseSensitive: false), '')
        .trim();
  }

  Future<void> _handleSaveAndExit() async {
    if (_isDeleted) {
      Navigator.pop(context);
      return;
    }

    FocusScope.of(context).unfocus();

    String title = _titleController.text.trim();
    String body = _bodyController.text.trim();
    if (title.isEmpty) title = 'Untitled Note';

    final String mergedContent = '$title\n$body';

    if (_vault.activeFile == null) {
      final directory = _vault.selectedDirectory;
      if ((title != 'Untitled Note' || body.isNotEmpty) && directory != null) {
        final uniquePath = await FileService.resolveUniqueFilePath(
          directory,
          '$title.md',
        );
        final uniqueFileName = uniquePath.split(Platform.pathSeparator).last;

        await _vault.createNewNote(uniqueFileName);
        _vault.updateContent(mergedContent);
        await _vault.saveActiveNote();

        if (_vault.activeFile != null) {
          _vault.setPin(_vault.activeFile!.path, _isPinned);
        }
      }
    } else {
      _vault.updateContent(mergedContent);
      if (_originalFilename != null) {
        final extension = _originalFilename!.contains('.')
            ? _originalFilename!.split('.').last
            : 'md';
        final desiredFileName = '$title.$extension';
        if (desiredFileName != _originalFilename) {
          await _vault.renameActiveNote(title);
        }
      }
      await _vault.saveActiveNote();

      if (_vault.activeFile != null) {
        _vault.setPin(_vault.activeFile!.path, _isPinned);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  void _onContentChanged(String _) {
    _refreshTags();
    if (_settings.autoSave && _vault.activeFile != null) {
      final merged = '${_titleController.text}\n${_bodyController.text}';
      _vault.updateContent(merged);
    }
  }

  // --- Options menu ----------------------------------------------------------

  void _showOptionsMenu() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _OptionsSheet(
        settings: _settings,
        currentTags: _currentTags,
        onAddTag: (tag) {
          _addTag(tag);
          Navigator.pop(sheetContext);
        },
        onRemoveTag: (tag) {
          _removeTag(tag);
        },
        onFontSize: (size) {
          _settings.setFontSize(size);
          setState(() {});
          Navigator.pop(sheetContext);
        },
        onCustomSize: () => _promptCustomSize(sheetContext),
        onDelete: () => _confirmDelete(sheetContext),
      ),
    );
  }

  void _promptCustomSize(BuildContext sheetContext) {
    final sizeController = TextEditingController(
      text: _settings.fontSize.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Obsidian.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Custom Font Size',
          style: TextStyle(color: Obsidian.text),
        ),
        content: TextField(
          controller: sizeController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Obsidian.text),
          cursorColor: Obsidian.emerald,
          decoration: const InputDecoration(
            hintText: 'Enter number (e.g. 18)',
            hintStyle: TextStyle(color: Obsidian.textDim),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Obsidian.emerald),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Obsidian.textDim),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Obsidian.emerald,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final parsed = double.tryParse(sizeController.text);
              if (parsed != null && parsed >= 10 && parsed <= 80) {
                _settings.setFontSize(parsed);
                setState(() {});
              }
              Navigator.pop(dialogCtx);
              Navigator.pop(sheetContext);
            },
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Obsidian.background,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext sheetContext) {
    if (_vault.activeFile == null) {
      _isDeleted = true;
      Navigator.pop(sheetContext);
      _handleSaveAndExit();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Obsidian.surfaceHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Note?',
          style: TextStyle(color: Obsidian.text, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This fragment will be removed from your localized vault. This cannot be undone.',
          style: TextStyle(color: Obsidian.textDim, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Obsidian.textDim),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Obsidian.dangerContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              _isDeleted = true;
              await _vault.deleteActiveNote();
              if (mounted) {
                Navigator.pop(dialogCtx);
                Navigator.pop(sheetContext);
                _handleSaveAndExit();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Obsidian.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Build -----------------------------------------------------------------

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Obsidian.background,
        body: Center(child: CircularProgressIndicator(color: Obsidian.emerald)),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await _handleSaveAndExit();
        return false;
      },
      child: Scaffold(
        backgroundColor: Obsidian.background,
        appBar: AppBar(
          backgroundColor: Obsidian.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Obsidian.text),
            onPressed: _handleSaveAndExit,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? Obsidian.emerald : Obsidian.textDim,
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  widget.file == null ? 'NEW RECORD' : 'WORKSPACE',
                  style: const TextStyle(
                    color: Obsidian.textDim,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Title field
                TextField(
                  controller: _titleController,
                  onChanged: _onContentChanged,
                  cursorColor: Obsidian.emerald,
                  textCapitalization: TextCapitalization.words,
                  style: Obsidian.manrope.copyWith(
                    color: Obsidian.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Note Title',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),

                // Body field
                // This entire layout block magically captures void-taps and maps
                // them to dynamically appended lines, saving you from pressing enter endlessly.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerUp: (event) {
                          if (!_bodyFocusNode.hasFocus) {
                            FocusScope.of(context).requestFocus(_bodyFocusNode);
                          }

                          // Get the absolute position of where the user tapped on the scrollable canvas
                          final double tapY = event.localPosition.dy;
                          final double scrollOffset =
                              _scrollController.hasClients
                              ? _scrollController.offset
                              : 0.0;
                          final double trueTapY = tapY + scrollOffset;

                          // Format our text string exactly as the TextPainter will see it
                          String textToMeasure = _bodyController.text;
                          if (textToMeasure.isEmpty) {
                            textToMeasure = ' ';
                          } else if (textToMeasure.endsWith('\n')) {
                            textToMeasure += ' ';
                          }

                          // Establish painter to find the exact rendering height (accounting for wrapping!)
                          final TextPainter painter = TextPainter(
                            text: TextSpan(
                              text: textToMeasure,
                              style: Obsidian.inter.copyWith(
                                color: Obsidian.text,
                                fontSize: _settings.fontSize,
                                height: 1.6,
                              ),
                            ),
                            textDirection: TextDirection.ltr,
                          );

                          painter.layout(maxWidth: constraints.maxWidth);
                          final double textHeight = painter.height;

                          // Only manipulate lines if they tapped visibly lower than our active text bound
                          if (trueTapY > textHeight + 10) {
                            final double diff = trueTapY - textHeight;
                            final double lineHeight = _settings.fontSize * 1.6;

                            // Map empty pixel space delta back into expected line breaks
                            final int linesToAdd = (diff / lineHeight).round();

                            if (linesToAdd > 0) {
                              Future.delayed(Duration.zero, () {
                                final String newText =
                                    _bodyController.text + ('\n' * linesToAdd);
                                _bodyController.value = TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                    offset: newText.length,
                                  ),
                                );
                                _onContentChanged('');
                              });
                            }
                          }
                        },
                        child: TextField(
                          focusNode: _bodyFocusNode,
                          controller: _bodyController,
                          scrollController: _scrollController,
                          onChanged: _onContentChanged,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          textCapitalization: TextCapitalization.sentences,
                          cursorColor: Obsidian.emerald,
                          style: Obsidian.inter.copyWith(
                            color: Obsidian.text,
                            fontSize: _settings.fontSize,
                            height: 1.6,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Transcribe the record...',
                            hintStyle: TextStyle(color: Colors.white24),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FloatingActionButton(
            backgroundColor: Obsidian.surfaceHighest,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: _showOptionsMenu,
            child: const Icon(Icons.menu, color: Obsidian.text),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Options Sheet — extracted as its own StatefulWidget so the tag input field
// has its own state without rebuilding the entire editor page.
// =============================================================================

class _OptionsSheet extends StatefulWidget {
  final SettingsService settings;
  final List<String> currentTags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<double> onFontSize;
  final VoidCallback onCustomSize;
  final VoidCallback onDelete;

  const _OptionsSheet({
    required this.settings,
    required this.currentTags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onFontSize,
    required this.onCustomSize,
    required this.onDelete,
  });

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  final TextEditingController _tagInputController = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.currentTags);
  }

  @override
  void dispose() {
    _tagInputController.dispose();
    super.dispose();
  }

  void _submitTag() {
    final raw = _tagInputController.text.trim();
    if (raw.isEmpty) return;
    // Strip leading # if user typed it
    final clean = raw.startsWith('#') ? raw.substring(1) : raw;
    if (clean.isEmpty) return;
    // Validate: letters/numbers/dash/underscore, starts with letter
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_\-]*$').hasMatch(clean)) return;
    final lower = clean.toLowerCase();
    if (_tags.contains(lower)) {
      _tagInputController.clear();
      return;
    }
    setState(() {
      _tags.add(lower);
      _tags.sort();
    });
    _tagInputController.clear();
    widget.onAddTag(lower);
  }

  bool _isActive(double size) => widget.settings.fontSize == size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Obsidian.surfaceHighest.withOpacity(0.95),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Canvas Options',
                  style: Obsidian.manrope.copyWith(
                    color: Obsidian.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Tags Section ─────────────────────────────────────────────
                Text(
                  'TAGS',
                  style: Obsidian.inter.copyWith(
                    color: Obsidian.textDim,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Tag input row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Obsidian.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Obsidian.emerald.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _tagInputController,
                          style: Obsidian.inter.copyWith(
                            color: Obsidian.text,
                            fontSize: 14,
                          ),
                          cursorColor: Obsidian.emerald,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitTag(),
                          decoration: InputDecoration(
                            hintText: '#tag-name',
                            hintStyle: TextStyle(
                              color: Obsidian.textDim.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.sell_outlined,
                              color: Obsidian.textDim,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _submitTag,
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          gradient: Obsidian.gemstoneGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Obsidian.emeraldDim,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                // Existing tag chips
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return _TagChip(
                        tag: tag,
                        onRemove: () {
                          setState(() => _tags.remove(tag));
                          widget.onRemoveTag(tag);
                        },
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 28),
                Container(height: 1, color: Obsidian.surfaceLow),
                const SizedBox(height: 24),

                // ── Text Scale Section ───────────────────────────────────────
                Text(
                  'TEXT SCALE',
                  style: Obsidian.inter.copyWith(
                    color: Obsidian.textDim,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _sizeCard('Normal', 16.0, 1.0),
                    _sizeCard('Medium', 20.0, 1.3),
                    _sizeCard('Large', 24.0, 1.6),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onCustomSize,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Obsidian.surfaceLow),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Use Custom Size',
                      style: Obsidian.manrope.copyWith(
                        color: Obsidian.textDim,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                Container(height: 1, color: Obsidian.surfaceLow),
                const SizedBox(height: 16),

                // ── Danger Zone ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Obsidian.danger,
                      size: 20,
                    ),
                    label: const Text(
                      'Destroy Record',
                      style: TextStyle(
                        color: Obsidian.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Obsidian.dangerContainer.withOpacity(
                        0.3,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sizeCard(String label, double targetSize, double iconScale) {
    final bool isActive = _isActive(targetSize);
    return Expanded(
      child: InkWell(
        onTap: () => widget.onFontSize(targetSize),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive
                ? Obsidian.emerald.withOpacity(0.1)
                : Obsidian.surfaceHigh,
            border: Border.all(
              color: isActive
                  ? Obsidian.emerald.withOpacity(0.5)
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'A',
                style: TextStyle(
                  color: isActive ? Obsidian.emerald : Obsidian.textDim,
                  fontSize: 16 * iconScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Obsidian.inter.copyWith(
                  color: isActive ? Obsidian.emerald : Obsidian.textDim,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small reusable tag chip with remove button
class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const _TagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Obsidian.emeraldDim.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Obsidian.emerald.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: Obsidian.inter.copyWith(
              color: Obsidian.emeraldLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Obsidian.emeraldLight,
            ),
          ),
        ],
      ),
    );
  }
}
