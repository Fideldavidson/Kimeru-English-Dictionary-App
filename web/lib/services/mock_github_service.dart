import 'dart:async';
import '../models/dictionary_entry.dart';
import 'github_service.dart';

class MockGitHubService extends GitHubService {
  List<DictionaryEntry> _mockData = [
    DictionaryEntry(
      id: "athana",
      pos: "v.tr.",
      definitions: ["to rule over, to govern."],
      examples: [
        DictionaryExample(
          kimeru: "Atiūmba kwathana miaka itano",
          english: "he will not be able to govern for five years.",
        ),
      ],
      cf: null,
      timestamp: 1737571325,
    ),
    DictionaryEntry(
      id: "baicikiri",
      pos: "n.",
      definitions: ["bicycle."],
      examples: [],
      cf: null,
      timestamp: 1737571325,
    ),
    DictionaryEntry(
      id: "athara",
      pos: "n.",
      definitions: ["loss, detriment, damage."],
      examples: [],
      cf: "acaara",
      timestamp: 1737571325,
    ),
  ];

  String _currentSha = "mock-sha-123";

  MockGitHubService() : super(owner: '', repo: '', path: '', token: '');

  @override
  Future<Map<String, dynamic>> fetchFileMetadata() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'sha': _currentSha};
  }

  @override
  Future<List<DictionaryEntry>> fetchDictionary() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockData);
  }

  @override
  Future<void> updateDictionary(List<DictionaryEntry> entries, String sha, String message) async {
    await Future.delayed(const Duration(seconds: 1));
    if (sha != _currentSha) {
      throw Exception('Conflict detected! (Mock Error)');
    }
    _mockData = List.from(entries);
    _currentSha = "mock-sha-${DateTime.now().millisecondsSinceEpoch}";
  }
}
