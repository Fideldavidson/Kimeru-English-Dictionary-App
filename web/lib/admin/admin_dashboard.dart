import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/github_service.dart';
import '../services/auth_service.dart';
import 'word_editor_dialog.dart';
import 'review_queue_page.dart';

class AdminDashboard extends StatefulWidget {
  final GitHubService githubService;
  final VoidCallback onLogout;

  const AdminDashboard({
    super.key, 
    required this.githubService,
    required this.onLogout,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<DictionaryEntry> _allEntries = [];
  List<DictionaryEntry> _filteredEntries = [];
  String? _currentSha;
  bool _loading = true;
  bool _publishing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final metadata = await widget.githubService.fetchFileMetadata();
      _currentSha = metadata['sha'];
      final entries = await widget.githubService.fetchDictionary();
      setState(() {
        _allEntries = entries;
        _filteredEntries = entries;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = _allEntries.where((e) => 
        e.id.toLowerCase().contains(query) || 
        e.definitions.any((d) => d.toLowerCase().contains(query))
      ).toList();
    });
  }

  Future<void> _publishChanges() async {
    if (_currentSha == null) return;
    
    setState(() => _publishing = true);
    try {
      // 1. Check for conflicts (Self-healing logic: fetch latest SHA)
      final metadata = await widget.githubService.fetchFileMetadata();
      final latestSha = metadata['sha'];
      
      if (latestSha != _currentSha) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conflict detected! Another admin has updated the dictionary. Please refresh.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() => _publishing = false);
        return;
      }

      // 2. Clear to publish
      await widget.githubService.updateDictionary(
        _allEntries, 
        _currentSha!, 
        'Manual update via admin dashboard'
      );
      // Refresh to get new SHA
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes published successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publish error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _showEditor([DictionaryEntry? entry]) async {
    final result = await showDialog<DictionaryEntry>(
      context: context,
      builder: (context) => WordEditorDialog(entry: entry),
    );

    if (result != null) {
      setState(() {
        if (entry == null) {
          _allEntries.insert(0, result);
        } else {
          int index = _allEntries.indexWhere((e) => e.id == entry.id);
          _allEntries[index] = result;
        }
        _onSearchChanged(); // Re-filter
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _loading ? null : () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewQueuePage(
                    initialDictionary: _allEntries,
                    onApplyChanges: (updatedEntries) {
                      setState(() {
                        _allEntries = updatedEntries;
                        _onSearchChanged();
                      });
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF Review Queue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5F7A),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _publishing || _loading ? null : _publishChanges,
            icon: _publishing 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.cloud_upload),
            label: const Text('Publish Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search words...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showEditor(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Word'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      child: ListView.separated(
                        itemCount: _filteredEntries.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = _filteredEntries[index];
                          return ListTile(
                            title: Text(entry.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${entry.pos} ${entry.definitions.join("; ")}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF1A5F7A)),
                              onPressed: () => _showEditor(entry),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
