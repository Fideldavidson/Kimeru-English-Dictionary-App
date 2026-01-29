import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictionary_entry.dart';

class GitHubSyncService {
  static const String _rawUrl = 
      'https://raw.githubusercontent.com/Fideldavidson/Kimeru-English-Dictionary-App/main/data/dictionary.json';

  /// Fetches the latest dictionary from the GitHub repository.
  /// Returns a list of DictionaryEntry objects.
  Future<List<DictionaryEntry>> fetchLatestDictionary() async {
    try {
      final response = await http.get(Uri.parse(_rawUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => DictionaryEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch dictionary: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
