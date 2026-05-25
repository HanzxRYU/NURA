import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/doa_model.dart';
import 'database_helper.dart';

/// Service kecil untuk memuat daftar Doa dari aset JSON dan
/// melakukan seed ke database lokal saat pertama kali aplikasi berjalan.
class DoaService {
  DoaService._();

  static final DoaService instance = DoaService._();

  /// Muat daftar Doa dari `assets/doa.json`.
  /// Mengembalikan list kosong jika format tidak sesuai.
  Future<List<DoaModel>> loadDoaFromAsset() async {
    final jsonText = await rootBundle.loadString('assets/doa.json');
    final decoded = jsonDecode(jsonText);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DoaModel.fromJson)
        .toList(growable: false);
  }

  /// Seed database bila kosong — memanggil `DatabaseHelper.init()` terlebih dahulu.
  Future<void> seedDatabaseIfNeeded() async {
    await DatabaseHelper.instance.init();

    if (await DatabaseHelper.instance.isEmpty()) {
      final doaList = await loadDoaFromAsset();
      await DatabaseHelper.instance.insertDoaList(doaList);
    }
  }
}
