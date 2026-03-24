import 'package:flutter/material.dart';
import '../obsidian_theme.dart';

class MobileSearchView extends StatefulWidget {
  const MobileSearchView({super.key});

  @override
  State<MobileSearchView> createState() => _MobileSearchViewState();
}

class _MobileSearchViewState extends State<MobileSearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Gets background from IndexedStack
      appBar: _buildTopHeader(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            // Search Input Container
            _buildSearchBar(),
            const SizedBox(height: 32),

            // Filter Chips Section
            _buildFilterChips(),
            const SizedBox(height: 40),

            // Conditional Logic: Show Recent Queries if empty, otherwise show Results/Empty state
            if (_query.isEmpty) _buildRecentQueries() else _buildEmptyState(),

            const SizedBox(height: 100), // Bottom Navigation bar padding buffer
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
      actions: [
        // App Logo Placeholder matching Vault View
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Obsidian.surfaceHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Subtle glow effect when typing
          color: _query.isNotEmpty
              ? Obsidian.emerald.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: _query.isNotEmpty
            ? [
                BoxShadow(
                  color: Obsidian.emerald.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _searchController,
        style: Obsidian.inter.copyWith(color: Obsidian.text, fontSize: 18),
        cursorColor: Obsidian.emerald,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: _query.isNotEmpty ? Obsidian.emerald : Obsidian.textDim,
          ),

          // Clear button if there's text, otherwise NO mic (completely clean input box)
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Obsidian.textDim),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = "");
                    FocusScope.of(context).unfocus(); // Drops keyboard
                  },
                )
              : null,

          hintText: "Search through the obsidian...",
          hintStyle: const TextStyle(color: Obsidian.textDim),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (val) => setState(() => _query = val),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "REFINE SEARCH",
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
          children: [
            _filterChip("Pinned", Icons.push_pin, isActive: true),
            _filterChip("Work", Icons.work_outline),
            _filterChip("Ideas", Icons.lightbulb_outline),
            _filterChip("Last 7 Days", Icons.calendar_today),
            _filterChip("Tags", Icons.sell_outlined),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, IconData icon, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Obsidian.emerald : Obsidian.surfaceHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? Colors.transparent
              : Obsidian.surfaceHighest.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? Obsidian.emeraldDim : Obsidian.textDim,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Obsidian.manrope.copyWith(
              color: isActive ? Obsidian.emeraldDim : Obsidian.textDim,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentQueries() {
    final recentSearches = [
      "Digital obsidian design philosophy",
      "Material 3 elevation system",
      "Emerald gemstone palette hex codes",
    ];

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
              onPressed: () {},
              child: Text(
                "CLEAR ALL",
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
        ...recentSearches.map(
          (query) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Obsidian.textDim),
              title: Text(
                query,
                style: Obsidian.inter.copyWith(color: Obsidian.text),
              ),
              trailing: const Icon(
                Icons.close,
                color: Obsidian.textDim,
                size: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => setState(() {
                _searchController.text = query;
                _query = query;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Obsidian.emerald.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Obsidian.emerald.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Void of Results",
            style: Obsidian.manrope.copyWith(
              color: Obsidian.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We couldn't find any fragments matching '$_query'. Try adjusting the emerald filters or broadening your terms.",
            textAlign: TextAlign.center,
            style: Obsidian.inter.copyWith(
              color: Obsidian.textDim,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
