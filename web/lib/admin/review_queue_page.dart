import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/pdf_parser_service.dart';
import 'word_editor_dialog.dart';

class ReviewQueuePage extends StatefulWidget {
  final List<DictionaryEntry> initialDictionary;
  final Function(List<DictionaryEntry>) onApplyChanges;

  const ReviewQueuePage({
    super.key,
    required this.initialDictionary,
    required this.onApplyChanges,
  });

  @override
  State<ReviewQueuePage> createState() => _ReviewQueuePageState();
}

class _ReviewQueuePageState extends State<ReviewQueuePage> {
  final TextEditingController _ocrController = TextEditingController();
  final PDFParserService _parserService = PDFParserService();
  List<DictionaryEntry> _stagedEntries = [];
  bool _isParsing = false;

  void _parseText() {
    if (_ocrController.text.isEmpty) return;
    
    setState(() => _isParsing = true);
    try {
      final newEntries = _parserService.parseText(_ocrController.text);
      setState(() {
        _stagedEntries = [...newEntries, ..._stagedEntries];
        _isParsing = false;
        _ocrController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parsed ${newEntries.length} entries.')),
      );
    } catch (e) {
      setState(() => _isParsing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parsing error: $e')),
      );
    }
  }

  void _editEntry(int index) async {
    final result = await showDialog<DictionaryEntry>(
      context: context,
      builder: (context) => WordEditorDialog(entry: _stagedEntries[index]),
    );

    if (result != null) {
      setState(() {
        _stagedEntries[index] = result;
      });
    }
  }

  void _removeEntry(int index) {
    setState(() {
      _stagedEntries.removeAt(index);
    });
  }

  void _applyAll() {
    if (_stagedEntries.isEmpty) return;
    
    final Map<String, DictionaryEntry> mergedMap = {
      for (var e in widget.initialDictionary) e.id: e
    };
    
    for (var e in _stagedEntries) {
      mergedMap[e.id] = e;
    }

    widget.onApplyChanges(mergedMap.values.toList());
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Applied staged entries to dictionary.'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Review Queue'),
        actions: [
          if (_stagedEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _applyAll,
                icon: const Icon(Icons.check_circle),
                label: Text('Apply All (${_stagedEntries.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left Side: OCR Input
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Paste OCR Text',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paste raw text from your PDF scanner. The engine will detect headwords marked with **.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _ocrController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '**athana** v.tr. to rule over...\n**baicikiri** n. bicycle...',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isParsing ? null : _parseText,
                      icon: _isParsing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.bolt),
                      label: const Text('Parse & Stage for Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5F7A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const VerticalDivider(width: 1),

          // Right Side: Staged Entries
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    '2. Review Staged Entries (${_stagedEntries.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _stagedEntries.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.queue_play_next, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Parsed entries will appear here', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _stagedEntries.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = _stagedEntries[index];
                              final hasErrors = entry.definitions.isEmpty;

                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: hasErrors ? Colors.red.withOpacity(0.5) : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            entry.id,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.teal[50],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              entry.pos,
                                              style: TextStyle(color: Colors.teal[800], fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (hasErrors)
                                            const Tooltip(
                                              message: 'Missing definitions!',
                                              child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Color(0xFF1A5F7A)),
                                            onPressed: () => _editEntry(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                            onPressed: () => _removeEntry(index),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Text(
                                        entry.definitions.isEmpty 
                                            ? '⚠️ No definition extracted' 
                                            : entry.definitions.join('; '),
                                        style: TextStyle(
                                          color: entry.definitions.isEmpty ? Colors.red : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (entry.examples.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Example: ${entry.examples.first.kimeru}',
                                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ],
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
        ],
      ),
    );
  }
}
