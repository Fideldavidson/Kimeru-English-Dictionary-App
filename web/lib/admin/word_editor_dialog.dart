import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../widgets/meru_character_bar.dart'; // Localized version for web

class WordEditorDialog extends StatefulWidget {
  final DictionaryEntry? entry;

  const WordEditorDialog({super.key, this.entry});

  @override
  State<WordEditorDialog> createState() => _WordEditorDialogState();
}

class _WordEditorDialogState extends State<WordEditorDialog> {
  final _idController = TextEditingController();
  final _posController = TextEditingController();
  final _defController = TextEditingController();
  final _exKController = TextEditingController();
  final _exEController = TextEditingController();
  final _refsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _idController.text = widget.entry!.id;
      _posController.text = widget.entry!.pos;
      _defController.text = widget.entry!.definitions.isNotEmpty ? widget.entry!.definitions.first : '';
      _exKController.text = widget.entry!.examples.isNotEmpty ? widget.entry!.examples.first.kimeru : '';
      _exEController.text = widget.entry!.examples.isNotEmpty ? widget.entry!.examples.first.english : '';
      _refsController.text = widget.entry!.cf ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.entry == null ? 'Add New Word' : 'Edit Word',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'Headword (Kimeru)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _posController,
                      decoration: const InputDecoration(labelText: 'POS (e.g., n., v.tr.)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _defController,
                decoration: const InputDecoration(labelText: 'English Definition'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _exKController,
                decoration: const InputDecoration(labelText: 'Example (Kimeru)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _exEController,
                decoration: const InputDecoration(labelText: 'Example Translation (English)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _refsController,
                decoration: const InputDecoration(labelText: 'Cross References (comma separated)'),
              ),
              const SizedBox(height: 24),
              const Text('Kimeru Character Utility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              // We need to pass the currently focused controller to the bar
              // For simplicity, we'll just use a small version here or skip for web if preferred
              // but the PRD asked for it.
              SizedBox(
                height: 50,
                child: MeruCharacterBar(
                  controller: _idController, // Default to headword for now
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final newEntry = DictionaryEntry(
                        id: _idController.text,
                        pos: _posController.text,
                        definitions: [_defController.text],
                        examples: _exKController.text.isNotEmpty 
                            ? [DictionaryExample(kimeru: _exKController.text, english: _exEController.text)] 
                            : [],
                        cf: _refsController.text.isEmpty ? null : _refsController.text,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                      );
                      Navigator.pop(context, newEntry);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5F7A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
