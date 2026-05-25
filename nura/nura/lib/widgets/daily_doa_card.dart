/// Kartu singkat untuk menampilkan Doa pilihan hari ini.
///
/// Menangani formatting teks, ukuran font dinamis, dan fallback jika data kosong.
import 'package:flutter/material.dart';

import '../models/doa_model.dart';

class DailyDoaCard extends StatelessWidget {
  final DoaModel doa;

  const DailyDoaCard({
    super.key,
    required this.doa,
  });

  @override
  Widget build(BuildContext context) {
    final title = doa.title.isEmpty ? 'Doa Pilihan Hari Ini' : doa.title;
    final titleSize = _titleFontSize(title);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF00A783),
              fontSize: titleSize,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              doa.arabic.isEmpty ? DoaModel.fallback.arabic : doa.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00A783),
                fontSize: 24,
                height: 1.9,
                fontWeight: FontWeight.w500,
                fontFamily: 'serif',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _translationText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00A783),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _translationText() {
    final translation = doa.translation.isEmpty
        ? DoaModel.fallback.translation
        : doa.translation;

    if (doa.source.isEmpty) {
      return '"$translation"';
    }

    return '"$translation" (${doa.source})';
  }

  double _titleFontSize(String title) {
    if (title.length > 54) {
      return 15;
    }

    if (title.length > 36) {
      return 16.5;
    }

    return 19;
  }
}
