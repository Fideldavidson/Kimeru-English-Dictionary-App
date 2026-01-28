import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _authKey = 'is_logged_in';
  
  // Simple MD5 hash of "kimeru2026" for demonstration
  // In production, use a more secure method or a true backend
  static const String _expectedHash = '12345'; // Placeholder

  Future<bool> login(String password) async {
    // For now, simple check - replace with real logic/API if needed
    if (password == 'kimeru2026') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authKey) ?? false;
  }
}
