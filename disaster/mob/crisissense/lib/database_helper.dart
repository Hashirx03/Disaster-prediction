import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If the database is not initialized, initialize it
    _database = await _initDB('predictions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create a table to store the prediction data
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        prediction_type TEXT,
        result TEXT,
        date_time TEXT
      )
    ''');
  }

  // Insert a prediction record
  Future<int> insertPrediction(String username, String predictionType, String result) async {
    final db = await instance.database;
    final dateTime = DateTime.now().toIso8601String(); // Current date and time
    final prediction = {
      'username': username,
      'prediction_type': predictionType,
      'result': result,
      'date_time': dateTime
    };
    return await db.insert('predictions', prediction);
  }

  // Retrieve all predictions
  Future<List<Map<String, dynamic>>> fetchAllPredictions() async {
    final db = await instance.database;
    return await db.query('predictions');
  }

  // Retrieve predictions by username
  Future<List<Map<String, dynamic>>> fetchPredictionsByUsername(String username) async {
    final db = await instance.database;
    return await db.query(
      'predictions',
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
