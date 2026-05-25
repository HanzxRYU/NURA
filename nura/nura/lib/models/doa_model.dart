/// Model data untuk sebuah entri Doa.
///
/// Mendukung parsing dari JSON fleksibel (beberapa variasi kunci),
/// peta SQLite (`fromMap`/`toMap`) dan fallback bila data tidak tersedia.
class DoaModel {
  final int? id;
  final String title;
  final String arabic;
  final String translation;
  final String source;
  final String category;

  const DoaModel({
    this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    this.source = '',
    this.category = '',
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      title: _readString(json, ['judul', 'title', 'nama', 'name']),
      arabic: _readString(json, [
        'arab',
        'arabic',
        'doa',
        'ayat',
        'teksArab',
        'text_arab',
        'teks_arab',
        'lafal',
        'lafadz',
        'bacaan',
      ]),
      translation: _readString(json, [
        'terjemah',
        'terjemahan',
        'translation',
        'arti',
        'indonesia',
        'indo',
        'idn',
        'teksIndonesia',
        'teks_indonesia',
        'text_indonesia',
        'makna',
        'terjemahan_id',
      ]),
      source: _readString(json, ['sumber', 'source', 'referensi', 'riwayat']),
      category: _readString(json, ['kategori', 'category', 'jenis']),
    );
  }


  /// Buat model dari hasil query SQLite (`Map<String, dynamic>`).
  factory DoaModel.fromMap(Map<String, dynamic> map) {
    return DoaModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? ''),
      title: _readString(map, ['title']),
      arabic: _readString(map, ['arabic']),
      translation: _readString(map, ['translation']),
      source: _readString(map, ['source']),
      category: _readString(map, ['category']),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'title': title,
      'arabic': arabic,
      'translation': translation,
      'source': source,
      'category': category,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final text = _stringFromValue(value);
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  static String _stringFromValue(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    if (value is num || value is bool) {
      return value.toString().trim();
    }

    if (value is Map<String, dynamic>) {
      return _readString(value, [
        'text',
        'teks',
        'arab',
        'arabic',
        'id',
        'indonesia',
        'terjemahan',
        'value',
      ]);
    }

    if (value is List) {
      return value
          .map(_stringFromValue)
          .where((item) => item.isNotEmpty)
          .join('\n');
    }

    return value.toString().trim();
  }

  static const fallback = DoaModel(
    title: 'Doa Sebelum Tidur',
    arabic:
        '\u0628\u0650\u0627\u0633\u0652\u0645\u0650\u0643\u064e \u0627\u0644\u0644\u0651\u0670\u0647\u064f\u0645\u0651\u064e \u0623\u064e\u062d\u0652\u064a\u064e\u0627 \u0648\u064e\u0628\u0650\u0627\u0633\u0652\u0645\u0650\u0643\u064e \u0623\u064e\u0645\u064f\u0648\u062a\u064f',
    translation:
        'Dengan nama-Mu ya Allah, aku hidup dan dengan nama-Mu aku mati.',
    source: 'HR. Bukhari',
  );
}
