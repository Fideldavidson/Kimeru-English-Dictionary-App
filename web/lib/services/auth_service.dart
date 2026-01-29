import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _authKey = 'is_logged_in';
  static const String _tokenKey = 'github_token';
  
  /// Verifies the token by calling GitHub API.
  /// Returns true if valid, false otherwise.
  Future<bool> login(String token) async {
    if (token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        // Token is valid! Save it.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authKey, true);
        await prefs.setString(_tokenKey, token);
        return true;
      }
    } catch (e) {
      print('Auth Error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authKey) ?? false;
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
