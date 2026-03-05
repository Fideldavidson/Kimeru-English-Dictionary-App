import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/local_database_service.dart';

class WordProvider with ChangeNotifier {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  DictionaryEntry? _wordOfTheDay;
  bool _isLoading = false;

  DictionaryEntry? get wordOfTheDay => _wordOfTheDay;
  bool get isLoading => _isLoading;

  WordProvider() {
    fetchWordOfTheDay();
  }

  Future<void> fetchWordOfTheDay() async {
    _isLoading = true;
    notifyListeners();

    try {
      final totalEntries = await _dbService.countEntries();
      if (totalEntries == 0) return;

      // Use the current date as a seed to ensure the word changes every 24 hours
      // and is consistent for all users.
      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      final random = Random(seed);
      
      // Since SQLite doesn't easily support fetching by a specific random index efficiently 
      // with a seed in a simple way, we jump to a random offset.
      final offset = random.nextInt(totalEntries);
      
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dictionary',
        limit: 1,
        offset: offset,
      );

      if (maps.isNotEmpty) {
        _wordOfTheDay = DictionaryEntry.fromMap(maps[0]);
      }
    } catch (e) {
      debugPrint('Error fetching word of the day: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
