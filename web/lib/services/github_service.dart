import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictionary_entry.dart';
import '../config/github_config.dart';

class GitHubService {
  final String owner;
  final String repo;
  final String path;
  final String token;

  GitHubService({
    String? owner,
    String? repo,
    String? path,
    String? token,
  }) : 
    owner = owner ?? GitHubConfig.owner,
    repo = repo ?? GitHubConfig.repo,
    path = path ?? GitHubConfig.path,
    token = token ?? GitHubConfig.token;

  String get _baseUrl => 'https://api.github.com/repos/$owner/$repo/contents/$path';

  Future<Map<String, dynamic>> fetchFileMetadata() async {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
    };
    
    if (token != 'YOUR_GITHUB_PAT_HERE' && token.isNotEmpty) {
      headers['Authorization'] = 'token $token';
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch file metadata: ${response.statusCode}');
    }
  }

  Future<List<DictionaryEntry>> fetchDictionary() async {
    final metadata = await fetchFileMetadata();
    final content = utf8.decode(base64Decode((metadata['content'] as String).replaceAll('\n', '')));
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList.map((e) => DictionaryEntry.fromJson(e)).toList();
  }

  Future<void> updateDictionary(List<DictionaryEntry> entries, String sha, String message) async {
    final jsonContent = jsonEncode(entries.map((e) => e.toJson()).toList());
    final encodedContent = base64Encode(utf8.encode(jsonContent));

    final response = await http.put(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
        'content': encodedContent,
        'sha': sha,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update dictionary: ${response.body}');
    }
  }
}
