import 'package:flutter/material.dart';

import '../models/doa_model.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../services/doa_service.dart';

/// Provider utama yang menyimpan data jadwal shalat dan daftar Doa.
///
/// Bertanggung jawab menginisialisasi data Doa dari local DB dan
/// mem-fetch data jadwal shalat dari `ApiService`.
class PrayerProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  final DoaService doaService = DoaService.instance;

  Map<String, dynamic>? data;
  DoaModel? dailyDoa;
  List<DoaModel> allDoa = [];
  PrayerLocation selectedLocation = PrayerLocation.rumpinBogor;

  bool isLoading = true;
  bool isDoaLoading = true;
  bool isSearchingLocation = false;
  String? locationSearchError;
  String? prayerError;

  PrayerProvider() {
    // Inisialisasi data Doa pada konstruktor.
    _initializeDoa();
  }

  /// Inisialisasi database Doa dan muat daftar Doa awal.
  Future<void> _initializeDoa() async {
    try {
      await doaService.seedDatabaseIfNeeded();
      allDoa = await databaseHelper.getAllDoa();
      dailyDoa = await databaseHelper.getRandomDoa();
    } catch (_) {
      // Jika terjadi error baca DB, fallback ke nilai default.
      allDoa = [];
      dailyDoa = DoaModel.fallback;
    } finally {
      isDoaLoading = false;
      notifyListeners();
    }
  }

  /// Ambil data jadwal shalat dari API.
  Future<void> fetchPrayerData() async {
    isLoading = true;
    prayerError = null;
    notifyListeners();

    try {
      data = await apiService.getPrayerData(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );

      if (!isDoaLoading) {
        allDoa = await databaseHelper.getAllDoa();
        dailyDoa = await databaseHelper.getRandomDoa();
      }
    } catch (_) {
      prayerError =
          'Jadwal shalat belum bisa dimuat. Periksa koneksi lalu coba lagi.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Cari Doa dalam memori `allDoa` yang sudah dimuat.
  List<DoaModel> searchDoa(String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return allDoa;
    }

    return allDoa
        .where((doa) {
          return doa.title.toLowerCase().contains(keyword) ||
              doa.translation.toLowerCase().contains(keyword) ||
              doa.category.toLowerCase().contains(keyword) ||
              doa.source.toLowerCase().contains(keyword);
        })
        .toList(growable: false);
  }

  Map<String, List<DoaModel>> groupDoa(List<DoaModel> doaList) {
    return databaseHelper.getGroupedDoa(doaList);
  }

  Future<void> changeLocation(PrayerLocation location) async {
    if (selectedLocation == location && data != null) {
      return;
    }

    selectedLocation = location;
    isLoading = true;
    locationSearchError = null;
    prayerError = null;
    notifyListeners();

    try {
      data = await apiService.getPrayerData(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (_) {
      prayerError =
          'Jadwal shalat belum bisa dimuat. Periksa koneksi lalu coba lagi.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchLocation(String query) async {
    final keyword = query.trim();

    if (keyword.isEmpty) {
      locationSearchError = 'Tulis nama kota dulu.';
      notifyListeners();
      return;
    }

    isSearchingLocation = true;
    isLoading = true;
    locationSearchError = null;
    prayerError = null;
    notifyListeners();

    try {
      final result = await apiService.searchLocation(keyword);
      final location = PrayerLocation(
        name: result.name,
        region: result.region,
        latitude: result.latitude,
        longitude: result.longitude,
      );

      selectedLocation = location;
      data = await apiService.getPrayerData(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (error) {
      locationSearchError = error is FormatException
          ? error.message
          : 'Lokasi belum bisa dicari. Coba lagi sebentar.';
    }

    isSearchingLocation = false;
    isLoading = false;
    notifyListeners();
  }
}

class PrayerLocation {
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  const PrayerLocation({
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  static const rumpinBogor = PrayerLocation(
    name: 'Rumpin',
    region: 'Bogor',
    latitude: -6.4698,
    longitude: 106.6359,
  );

  String get displayName {
    if (region.trim().isEmpty) {
      return name;
    }

    return '$name, $region';
  }

  String get coordinateText {
    final latDirection = latitude >= 0 ? 'LU' : 'LS';
    final lonDirection = longitude >= 0 ? 'BT' : 'BB';

    return '${latitude.abs().toStringAsFixed(4)} $latDirection, '
        '${longitude.abs().toStringAsFixed(4)} $lonDirection';
  }
}
