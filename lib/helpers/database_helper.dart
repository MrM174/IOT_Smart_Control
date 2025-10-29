// lib/helpers/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // --- CAMBIO CLAVE ---
    // Cambiamos el nombre para forzar la creación de una base de datos nueva.
    _database = await _initDB('sensors_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Ya no necesitamos onUpgrade porque estamos creando una DB nueva.
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realTypeNullable = 'REAL'; 

    await db.execute('''
      CREATE TABLE sensor_readings ( 
        id $idType, 
        temperature $realTypeNullable,
        humidity $realTypeNullable,
        airQuality $realTypeNullable,
        timestamp $textType
      )
    ''');
  }

  Future<void> createReading({
    double? temperature,
    double? humidity,
    double? airQuality,
    required String timestamp,
  }) async {
    final db = await instance.database;
    await db.insert('sensor_readings', {
      'temperature': temperature,
      'humidity': humidity,
      'airQuality': airQuality,
      'timestamp': timestamp,
    });
  }

  Future<List<Map<String, dynamic>>> getTempHumReadings() async {
    final db = await instance.database;
    return await db.query('sensor_readings',
        where: 'temperature IS NOT NULL AND humidity IS NOT NULL',
        orderBy: 'id DESC',
        limit: 100);
  }
  
  Future<List<Map<String, dynamic>>> getAirQualityReadings() async {
    final db = await instance.database;
    return await db.query('sensor_readings',
        where: 'airQuality IS NOT NULL',
        orderBy: 'id DESC',
        limit: 100);
  }
}