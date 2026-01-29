import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/github_service.dart';
import '../widgets/meru_character_bar.dart'; // We'll need to share this or recreate for web

class PublicSearchPage extends StatefulWidget {
  final GitHubService githubService;
  final VoidCallback onAdminLogin;

  const PublicSearchPage({
    super.key, 
    required this.githubService,
    required this.onAdminLogin,
  });

  @override
  State<PublicSearchPage> createState() => _PublicSearchPageState();
}

class _PublicSearchPageState extends State<PublicSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DictionaryEntry> _allEntries = [];
  List<DictionaryEntry> _searchResults = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final entries = await widget.githubService.fetchDictionary();
      setState(() {
        _allEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dictionary: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allEntries.where((entry) {
          final q = query.toLowerCase();
          return entry.id.toLowerCase().contains(q) ||
                 entry.definitions.any((d) => d.toLowerCase().contains(q));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kimeru Dictionary'),
        actions: [
          TextButton(
            onPressed: widget.onAdminLogin,
            child: const Text('Admin', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Search Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1A5F7A),
            ),
            child: Column(
              children: [
                const Text(
                  'Search the Kimeru Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Type a word in Kimeru or English...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _query.isEmpty
                    ? _buildWelcomeContent()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined, size: 100, color: Color(0xFF1A5F7A)),
            const SizedBox(height: 24),
            const Text(
              'Welcome to the Kimeru Digital Dictionary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'A community-driven project to preserve and promote the Kimeru language.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoCard('Verified Words', '${_allEntries.length}+'),
                _buildInfoCard('Language', 'Kimeru/English'),
                _buildInfoCard('Type', 'Community Project'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No words found for your search.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final entry = _searchResults[index];
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.id,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5F7A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.pos,
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...entry.definitions.map((def) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(def, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                )),
                if (entry.examples.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Examples:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  ...entry.examples.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.kimeru, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(ex.english, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
