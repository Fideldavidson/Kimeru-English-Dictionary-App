import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dictionary_entry.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;

  Future<int> countEntries() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM dictionary');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kimeru_dictionary_v2.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
         // Simply recreate for prototype if versions change
         await db.execute('DROP TABLE IF EXISTS dictionary');
         await db.execute('DROP TABLE IF EXISTS dictionary_fts');
         await _onCreate(db, newVersion);
      }
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Regular table for storage
    await db.execute('''
      CREATE TABLE dictionary (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT UNIQUE,
        pos TEXT,
        definitions TEXT,
        examples TEXT,
        note TEXT,
        synonym TEXT,
        origin TEXT,
        cf TEXT,
        timestamp INTEGER
      )
    ''');

    // FTS5 table for fast search
    await db.execute('''
      CREATE VIRTUAL TABLE dictionary_fts USING fts5(
        headword,
        definitions,
        examples,
        tokenize='unicode61'
      )
    ''');
  }

  Future<void> insertOrUpdateEntries(List<DictionaryEntry> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var entry in entries) {
        final map = entry.toMap();
        
        // Update main table
        await txn.insert(
          'dictionary',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        // FTS Sync
        final examplesText = entry.examples.map((e) => "${e.kimeru} ${e.english}").join(' ');
        
        await txn.delete('dictionary_fts', where: 'headword = ?', whereArgs: [entry.id]);
        await txn.insert('dictionary_fts', {
          'headword': entry.id,
          'definitions': entry.definitions.join(' '),
          'examples': examplesText,
        });
      }
    });
  }

  Future<List<DictionaryEntry>> searchEntries(String query) async {
    if (query.isEmpty) return [];
    
    final db = await database;
    
    // Search FTS5
    final List<Map<String, dynamic>> ftsResults = await db.rawQuery('''
      SELECT headword FROM dictionary_fts 
      WHERE dictionary_fts MATCH ? 
      ORDER BY rank 
      LIMIT 100
    ''', ['$query*']);
    
    if (ftsResults.isEmpty) return [];
    
    final List<String> headwords = ftsResults.map((m) => m['headword'] as String).toList();
    
    // Fetch full entries from main table
    // Handle IN clause with placeholders
    final String placeholders = headwords.map((_) => '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'dictionary',
      where: 'id IN ($placeholders)',
      whereArgs: headwords,
    );

    // Re-sort to match FTS ranking
    final entryMap = {for (var m in maps) m['id']: DictionaryEntry.fromMap(m)};
    return headwords
      .map((h) => entryMap[h])
      .where((e) => e != null)
      .cast<DictionaryEntry>()
      .toList();
  }

  Future<List<DictionaryEntry>> getRandomEntries(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dictionary',
      orderBy: 'RANDOM()',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return DictionaryEntry.fromMap(maps[i]);
    });
  }
}
