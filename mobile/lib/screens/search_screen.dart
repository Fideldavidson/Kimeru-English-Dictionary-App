import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/local_database_service.dart';
import '../widgets/meru_character_bar.dart';
import '../widgets/word_of_day_card.dart';
import '../widgets/category_filter_bar.dart';
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

  // Placeholder for "Word of the Day" - To be replaced with dynamic content later
  final DictionaryEntry _mockWOTD = DictionaryEntry(
    id: "Mugwe",
    pos: "noun",
    definitions: ["A religious leader or prophet within the traditional Meru spiritual structure, serving as a mediator between God and the people."],
    examples: [
      DictionaryExample(kimeru: "Mugwe niwe wambiriirie guthoma.", english: "The Mugwe was the one who started the prayer.")
    ],
    cf: "Njuri Ncheke",
    timestamp: 1737571325,
  );

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kimeru',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black87),
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
                decoration: InputDecoration(
                  hintText: 'Search Kimeru or English...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
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

            // Meru Character Bar (Only shown when searching/keyboard is likely up)
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 16),
        WordOfTheDayCard(
          entry: _mockWOTD,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WordDetailScreen(entry: _mockWOTD)),
          ),
        ),
        const SizedBox(height: 24),
        CategoryFilterBar(
          categories: const ['All', 'Nouns', 'Verbs', 'Proverbs'],
          onSelected: (cat) {},
        ),
        const SizedBox(height: 32),
        const Text(
          'RECENT WORDS', // Effectively "Discover" for now
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        if (_recentWords.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ))
        else
          ..._recentWords.map((entry) => _buildRecentItem(
            entry.id, 
            entry.pos, 
            entry.definitions.isNotEmpty ? entry.definitions.first : '',
            entry: entry
          )).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _results[index];
        return _buildRecentItem(
          entry.id, 
          entry.pos, 
          entry.definitions.isNotEmpty ? entry.definitions.first : '', 
          entry: entry
        );
      },
    );
  }

  Widget _buildRecentItem(String title, String pos, String snippet, {DictionaryEntry? entry}) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      child: InkWell(
        onTap: () {
          if (entry != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WordDetailScreen(entry: entry)),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pos,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snippet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
