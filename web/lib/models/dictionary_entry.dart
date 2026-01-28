import 'dart:convert';

class DictionaryExample {
  final String kimeru;
  final String english;

  DictionaryExample({required this.kimeru, required this.english});

  Map<String, String> toJson() => {'kimeru': kimeru, 'english': english};

  factory DictionaryExample.fromJson(Map<String, dynamic> json) =>
      DictionaryExample(
        kimeru: json['kimeru'] ?? '',
        english: json['english'] ?? '',
      );
}

class DictionaryEntry {
  final String id; // Headword
  final String pos;
  final List<String> definitions;
  final List<DictionaryExample> examples;
  final String? note;
  final String? synonym;
  final String? origin;
  final String? cf;
  final int timestamp;

  DictionaryEntry({
    required this.id,
    required this.pos,
    required this.definitions,
    required this.examples,
    this.note,
    this.synonym,
    this.origin,
    this.cf,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'headword': id,
    'pos': pos,
    'definitions': definitions,
    'examples': examples.map((e) => e.toJson()).toList(),
    'note': note,
    'synonym': synonym,
    'origin': origin,
    'cf': cf,
    'timestamp': timestamp,
  };

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) => 
    DictionaryEntry(
      id: json['headword'] ?? json['id'] ?? '',
      pos: json['pos'] ?? '',
      definitions: List<String>.from(json['definitions'] ?? []),
      examples: (json['examples'] as List?)?.map((e) => DictionaryExample.fromJson(e)).toList() ?? [],
      note: json['note'],
      synonym: json['synonym'],
      origin: json['origin'],
      cf: json['cf'],
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
}
