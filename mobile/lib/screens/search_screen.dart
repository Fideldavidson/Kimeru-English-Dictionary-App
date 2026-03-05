import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/local_database_service.dart';
import '../widgets/meru_character_bar.dart';
import '../widgets/mugwe_card.dart';
import '../widgets/google_loader.dart';
import 'word_detail_screen.dart';
import 'settings_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocalDatabaseService _dbService = LocalDatabaseService();
  List<DictionaryEntry> _results = [];
  List<DictionaryEntry> _recentWords = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentWords();
  }

  Future<void> _loadRecentWords() async {
    final words = await _dbService.getRandomEntries(5);
    if (mounted) {
      setState(() {
        _recentWords = words;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    setState(() => _isSearching = text.isNotEmpty);
    _performSearch(text);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final results = await _dbService.searchEntries(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kimeru',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search Kimeru or English...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildHomeScreen(),
            ),

            // Meru Character Bar
            MeruCharacterBar(
              controller: _searchController,
              onCharacterPressed: _onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const MugweCard(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'DISCOVER',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_recentWords.isEmpty)
          const GoogleLoader()
        else
          ..._recentWords.map((entry) => _buildResultItem(entry)).toList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const GoogleLoader();
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) => _buildResultItem(_results[index]),
    );
  }

  Widget _buildResultItem(DictionaryEntry entry) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WordDetailScreen(entry: entry)),
          );
        },
        title: Row(
          children: [
            Text(
              entry.id,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.pos,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        subtitle: Text(
          entry.definitions.isNotEmpty ? entry.definitions.first : '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
