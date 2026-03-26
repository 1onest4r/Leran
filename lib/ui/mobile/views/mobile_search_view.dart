import 'dart:io';
import 'package:flutter/material.dart';
import '../obsidian_theme.dart';
import '../../../logic/vault_controller.dart';
import '../../../services/file_service.dart';
import 'mobile_vault_view.dart'; // To reuse DynamicNoteCard

class MobileSearchView extends StatefulWidget {
  const MobileSearchView({super.key});

  @override
  State<MobileSearchView> createState() => _MobileSearchViewState();
}

class _MobileSearchViewState extends State<MobileSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final VaultController _vault = VaultController();

  String _query = '';
  List<FileSystemEntity> _searchResults = [];
  List<String> _allVaultTags = [];
  static List<String> _recentQueries =
      []; // Static to persist during app session

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _vault.getAllUniqueTags();
    if (mounted) setState(() => _allVaultTags = tags);
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final List<FileSystemEntity> results = [];
    final lowerQuery = query.toLowerCase();

    for (final file in _vault.files) {
      final filename = file.uri.pathSegments.last.toLowerCase();
      // Search title
      if (filename.contains(lowerQuery)) {
        results.add(file);
        continue;
      }

      // Search content
      try {
        final content = await FileService.readFile(file);
        if (content.toLowerCase().contains(lowerQuery)) {
          results.add(file);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _query = query;
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _saveQuery(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _recentQueries.remove(query); // Remove duplicate
      _recentQueries.insert(0, query); // Add to top
      if (_recentQueries.length > 5) _recentQueries.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildTopHeader(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  if (_query.isEmpty) ...[
                    _buildFilterChips(),
                    const SizedBox(height: 40),
                    _buildRecentQueries(),
                  ] else ...[
                    _buildResultsList(),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
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
        "ARCHIVE",
        style: Obsidian.manrope.copyWith(
          color: Obsidian.emerald,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Obsidian.surfaceHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _query.isNotEmpty
              ? Obsidian.emerald.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: Obsidian.inter.copyWith(color: Obsidian.text, fontSize: 18),
        cursorColor: Obsidian.emerald,
        textInputAction: TextInputAction.search,
        onSubmitted: (val) => _saveQuery(val),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: _query.isNotEmpty ? Obsidian.emerald : Obsidian.textDim,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Obsidian.textDim),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch("");
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          hintText: "Search titles or content...",
          hintStyle: TextStyle(color: Obsidian.textDim),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: _performSearch,
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_allVaultTags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "REFINE BY TAG",
          style: Obsidian.manrope.copyWith(
            color: Obsidian.textDim,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allVaultTags.map((tag) => _tagChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _tagChip(String tag) {
    return GestureDetector(
      onTap: () {
        final tagQuery = "#$tag";
        _searchController.text = tagQuery;
        _performSearch(tagQuery);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Obsidian.surfaceHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Obsidian.emerald.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sell_outlined, size: 14, color: Obsidian.emerald),
            const SizedBox(width: 8),
            Text(
              tag,
              style: Obsidian.manrope.copyWith(
                color: Obsidian.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentQueries() {
    if (_recentQueries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "RECENT QUERIES",
              style: Obsidian.manrope.copyWith(
                color: Obsidian.textDim,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _recentQueries.clear()),
              child: Text(
                "CLEAR",
                style: Obsidian.manrope.copyWith(
                  color: Obsidian.emerald,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentQueries.map(
          (q) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history, color: Obsidian.textDim, size: 20),
            title: Text(
              q,
              style: Obsidian.inter.copyWith(color: Obsidian.text),
            ),
            trailing: Icon(
              Icons.arrow_outward,
              color: Obsidian.textDim,
              size: 16,
            ),
            onTap: () {
              _searchController.text = q;
              _performSearch(q);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: Obsidian.emerald),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RESULTS FOUND: ${_searchResults.length}",
          style: Obsidian.manrope.copyWith(
            color: Obsidian.textDim,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ..._searchResults.map((file) => DynamicNoteCard(file: file)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Obsidian.textDim.withOpacity(0.2),
          ),
          const SizedBox(height: 24),
          Text(
            "No fragments found",
            style: Obsidian.manrope.copyWith(
              color: Obsidian.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try a different term or a specific tag.",
            style: Obsidian.inter.copyWith(color: Obsidian.textDim),
          ),
        ],
      ),
    );
  }
}
