import '../models/dictionary_entry.dart';

class PDFParserService {
  /// Primary pattern to detect the start of a dictionary entry.
  /// Matches bold headwords like **athana** followed by POS tags like v.tr.
  final RegExp entryHeaderPattern = RegExp(
    r'\*\*([^*]+)\*\*\s+([a-z-]+\.(?:\s*[a-z-]+\.)?)\s+',
  );

  /// Patterns to detect common sections within an entry.
  final RegExp cfPattern = RegExp(r'\s*cf:\s*\*\*([^*]+)\*\*');
  final RegExp originPattern = RegExp(r'\s*\(Origin:\s*([^)]+)\)');
  final RegExp synonymPattern = RegExp(r'\s*Synonym:\s*([^.]+)\.');

  List<DictionaryEntry> parseText(String rawText) {
    final List<DictionaryEntry> entries = [];
    
    // 1. Identify all potential entry start positions
    final matches = entryHeaderPattern.allMatches(rawText).toList();
    
    for (int i = 0; i < matches.length; i++) {
      final headerMatch = matches[i];
      final headword = headerMatch.group(1)!.trim();
      final pos = headerMatch.group(2)!.trim();
      
      // Get the block of text belonging to this entry
      // It's the text from this match to the start of the next match (or end of string)
      final start = headerMatch.end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : rawText.length;
      String body = rawText.substring(start, end).trim();

      // 2. Extract Cross-references (cf:)
      String? cf;
      final cfMatch = cfPattern.firstMatch(body);
      if (cfMatch != null) {
        cf = cfMatch.group(1);
        body = body.replaceAll(cfPattern, '').trim();
      }

      // 3. Extract Metadata (Origin, Synonym)
      String? origin;
      final originMatch = originPattern.firstMatch(body);
      if (originMatch != null) {
        origin = originMatch.group(1);
        body = body.replaceAll(originPattern, '').trim();
      }

      String? synonym;
      final synonymMatch = synonymPattern.firstMatch(body);
      if (synonymMatch != null) {
        synonym = synonymMatch.group(1);
        body = body.replaceAll(synonymPattern, '').trim();
      }

      // 4. Split definitions and examples
      // Simple heuristic: Sentences starting with Uppercase followed by lowercase
      // are often Kimeru examples.
      final List<String> definitions = [];
      final List<DictionaryExample> examples = [];
      
      // Split by common sentence delimiters
      final segments = body.split(RegExp(r'\.\s+'));
      
      for (var segment in segments) {
        segment = segment.trim();
        if (segment.isEmpty) continue;

        // Check if it looks like an example: "Kimeru sentence english meaning."
        // Pattern: [Capital start] ... [lowercase start of English part]
        final exampleMatch = RegExp(r'^([A-ZĨŨĀĒĪŌŪ][^a-z]+[a-z].*?)\s+([a-z].*)$').firstMatch(segment);
        
        if (exampleMatch != null) {
          examples.add(DictionaryExample(
            kimeru: exampleMatch.group(1)!.trim(),
            english: exampleMatch.group(2)!.trim(),
          ));
        } else {
          // If not an example, it's a definition
          definitions.add(segment);
        }
      }

      entries.add(DictionaryEntry(
        id: headword,
        pos: pos,
        definitions: definitions,
        examples: examples,
        cf: cf,
        origin: origin,
        synonym: synonym,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    return entries;
  }
}
