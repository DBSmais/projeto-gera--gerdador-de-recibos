import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/recibo_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, 'recibos.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recibos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pagador TEXT NOT NULL,
        recebedor TEXT NOT NULL,
        outroAgente TEXT,
        valor REAL NOT NULL,
        descricao TEXT NOT NULL,
        data TEXT NOT NULL,
        formaPagamento TEXT NOT NULL,
        cpfCnpj TEXT,
        endereco TEXT,
        criadoEm TEXT,
        atualizadoEm TEXT,
        hashSeguranca TEXT
      )
    ''');
  }

  Future<int> insertRecibo(ReciboModel recibo) async {
    final db = await database;
    final now = DateTime.now();
    final reciboWithTimestamps = recibo.copyWith(
      criadoEm: recibo.criadoEm ?? now,
      atualizadoEm: now,
    );
    return await db.insert('recibos', reciboWithTimestamps.toMap());
  }

  Future<List<ReciboModel>> getAllRecibos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recibos',
      orderBy: 'data DESC, criadoEm DESC',
    );
    return List.generate(maps.length, (i) => ReciboModel.fromMap(maps[i]));
  }

  Future<ReciboModel?> getReciboById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recibos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ReciboModel.fromMap(maps.first);
  }

  Future<List<ReciboModel>> searchRecibos(String query) async {
    final db = await database;
    final searchQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'recibos',
      where: 'pagador LIKE ? OR recebedor LIKE ? OR descricao LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'data DESC, criadoEm DESC',
    );
    return List.generate(maps.length, (i) => ReciboModel.fromMap(maps[i]));
  }

  Future<List<ReciboModel>> filterRecibosByDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recibos',
      where: 'data >= ? AND data <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'data DESC, criadoEm DESC',
    );
    return List.generate(maps.length, (i) => ReciboModel.fromMap(maps[i]));
  }

  Future<List<ReciboModel>> filterRecibosByValue(
    double minValue,
    double maxValue,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recibos',
      where: 'valor >= ? AND valor <= ?',
      whereArgs: [minValue, maxValue],
      orderBy: 'data DESC, criadoEm DESC',
    );
    return List.generate(maps.length, (i) => ReciboModel.fromMap(maps[i]));
  }

  Future<int> updateRecibo(ReciboModel recibo) async {
    final db = await database;
    final updatedRecibo = recibo.copyWith(atualizadoEm: DateTime.now());
    return await db.update(
      'recibos',
      updatedRecibo.toMap(),
      where: 'id = ?',
      whereArgs: [recibo.id],
    );
  }

  Future<int> deleteRecibo(int id) async {
    final db = await database;
    return await db.delete(
      'recibos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalRecebido() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM recibos',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalRecibos() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM recibos');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

