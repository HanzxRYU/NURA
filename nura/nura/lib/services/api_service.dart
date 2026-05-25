import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/doa_model.dart';

class ApiService {
  static const Duration _requestTimeout = Duration(seconds: 12);

  Future<Map<String, dynamic>> getPrayerData({
    double latitude = -6.4698,
    double longitude = 106.6359,
  }) async {
    final response = await http
        .get(
          Uri.https('api.aladhan.com', '/v1/timings', {
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'method': '8',
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Jadwal shalat belum bisa dimuat saat ini.');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> ||
        data['data'] is! Map<String, dynamic>) {
      throw const FormatException('Format jadwal shalat tidak sesuai.');
    }

    return Map<String, dynamic>.from(data['data']);
  }

  Future<GeocodedLocation> searchLocation(String query) async {
    final keyword = query.trim();

    if (keyword.isEmpty) {
      throw const FormatException('Nama kota belum diisi.');
    }

    final response = await http
        .get(
          Uri.https('nominatim.openstreetmap.org', '/search', {
            'q': keyword,
            'format': 'jsonv2',
            'addressdetails': '1',
            'limit': '1',
          }),
          headers: const {'User-Agent': 'NuraPrayerTimeApp/1.0'},
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Lokasi belum bisa dicari saat ini.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      throw FormatException('Kota "$keyword" tidak ditemukan.');
    }

    final item = decoded.first;
    if (item is! Map<String, dynamic>) {
      throw FormatException('Kota "$keyword" tidak ditemukan.');
    }

    final latitude = double.tryParse(item['lat']?.toString() ?? '');
    final longitude = double.tryParse(item['lon']?.toString() ?? '');

    if (latitude == null || longitude == null) {
      throw FormatException('Koordinat "$keyword" tidak ditemukan.');
    }

    final address = item['address'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(item['address'])
        : <String, dynamic>{};
    final name = _firstText([
      address['city'],
      address['town'],
      address['municipality'],
      address['county'],
      item['name'],
      keyword,
    ]);
    final region = _firstText([
      address['state'],
      address['province'],
      address['region'],
      address['country'],
    ]);

    return GeocodedLocation(
      name: name,
      region: region,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<DoaModel> getRandomDoa() async {
    try {
      final random = Random();

      for (var attempt = 0; attempt < 3; attempt++) {
        final id = random.nextInt(228) + 1;
        final response = await http
            .get(Uri.parse('https://equran.id/api/doa/$id'))
            .timeout(_requestTimeout);

        if (response.statusCode != 200) {
          continue;
        }

        final decoded = jsonDecode(response.body);
        final detail = _extractDoaDetail(decoded);
        final doa = DoaModel.fromJson(detail);

        if (doa.arabic.isNotEmpty && doa.translation.isNotEmpty) {
          return doa;
        }
      }

      return DoaModel.fallback;
    } catch (_) {
      return DoaModel.fallback;
    }
  }

  Map<String, dynamic> _extractDoaDetail(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final possibleData = decoded['data'] ?? decoded['doa'] ?? decoded['item'];
      if (possibleData is Map<String, dynamic>) {
        return possibleData;
      }

      return decoded;
    }

    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          return item;
        }
      }
    }

    return {};
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }
}

class GeocodedLocation {
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  const GeocodedLocation({
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });
}
