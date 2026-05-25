import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/doa_model.dart';

/// SQLite helper untuk mengelola tabel Doa.
///
/// Menyediakan inisialisasi database, operasi pembacaan, pencarian, dan
/// operasi batch insert untuk seed data.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'nura_doa.db';
  static const _databaseVersion = 1;
  static const _tableDoa = 'doa';

  static const _columnId = 'id';
  static const _columnTitle = 'title';
  static const _columnArabic = 'arabic';
  static const _columnTranslation = 'translation';
  static const _columnSource = 'source';
  static const _columnCategory = 'category';

  Database? _database;
  final Random _random = Random();

  /// Ambil instance database (membuka file DB jika belum ada).
  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return _database!;
  }

  /// Inisialisasi database (panggil saat app startup jika perlu).
  Future<void> init() async {
    await _getDatabase();
  }

  /// Buat struktur tabel saat database pertama kali dibuat.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableDoa (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnTitle TEXT NOT NULL,
        $_columnArabic TEXT NOT NULL,
        $_columnTranslation TEXT NOT NULL,
        $_columnSource TEXT NOT NULL,
        $_columnCategory TEXT NOT NULL
      )
    ''');
  }

  Future<bool> isEmpty() async {
    final db = await _getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableDoa');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }

  /// Masukkan list Doa dalam satu batch (efisien untuk seed awal).
  Future<void> insertDoaList(List<DoaModel> doaList) async {
    if (doaList.isEmpty) {
      return;
    }

    final db = await _getDatabase();
    final batch = db.batch();

    for (final doa in doaList) {
      batch.insert(
        _tableDoa,
        doa.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Ambil semua Doa, diurutkan berdasarkan kategori lalu judul.
  Future<List<DoaModel>> getAllDoa() async {
    final db = await _getDatabase();
    final rows = await db.query(
      _tableDoa,
      orderBy: '$_columnCategory, $_columnTitle',
    );
    return rows.map(DoaModel.fromMap).toList(growable: false);
  }

  /// Pilih satu Doa secara acak dari tabel.
  Future<DoaModel> getRandomDoa() async {
    final allDoa = await getAllDoa();
    if (allDoa.isEmpty) {
      return DoaModel.fallback;
    }

    return allDoa[_random.nextInt(allDoa.length)];
  }

  /// Pencarian Doa menggunakan query LIKE di beberapa kolom.
  Future<List<DoaModel>> searchDoa(String query) async {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return getAllDoa();
    }

    final db = await _getDatabase();
    final likeKeyword = '%$keyword%';
    final rows = await db.rawQuery(
      '''
      SELECT * FROM $_tableDoa
      WHERE LOWER($_columnTitle) LIKE ?
        OR LOWER($_columnTranslation) LIKE ?
        OR LOWER($_columnCategory) LIKE ?
        OR LOWER($_columnSource) LIKE ?
      ORDER BY $_columnCategory, $_columnTitle
      ''',
      [likeKeyword, likeKeyword, likeKeyword, likeKeyword],
    );

    return rows.map(DoaModel.fromMap).toList(growable: false);
  }

  /// Kumpulkan daftar kategori unik dari sumber (atau list kosong jika tidak ada).
  List<String> getCategories([List<DoaModel>? source]) {
    final categoryList = (source ?? [])
        .map((doa) => doa.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categoryList.sort();
    return categoryList;
  }

  /// Kelompokkan daftar Doa berdasarkan kategori.
  Map<String, List<DoaModel>> getGroupedDoa([List<DoaModel>? source]) {
    final grouped = <String, List<DoaModel>>{};

    for (final doa in source ?? []) {
      grouped.putIfAbsent(doa.category, () => []).add(doa);
    }

    return grouped;
  }
}

