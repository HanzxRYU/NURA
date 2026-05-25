import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/doa_model.dart';
import '../providers/prayer_provider.dart';
import '../widgets/daily_doa_card.dart';

/// Halaman untuk menampilkan daftar Doa.
///
/// Menangani pencarian lokal (dengan data yang sudah dimuat oleh provider),
/// serta menampilkan kartu Doa harian dan daftar Doa yang dikelompokkan.
class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFB8D8D0);
    final titleColor = theme.colorScheme.onSurface;
    final mutedColor =
        isDark ? const Color(0xFFA8C6BE) : const Color(0xFF5D7770);

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Consumer<PrayerProvider>(
          builder: (context, provider, child) {
            // Tampilkan loading spinner jika provider masih melakukan inisialisasi DB.
            if (provider.isDoaLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF08745F),
                ),
              );
            }

            final dailyDoa = provider.dailyDoa ?? DoaModel.fallback;
            final doaList = provider.searchDoa(_query);
            final groupedDoa = provider.groupDoa(doaList);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 112),
              children: [
                Text(
                  'Doa Harian',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${provider.allDoa.length} doa tersimpan untuk dibaca offline',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                DailyDoaCard(doa: dailyDoa),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari doa',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF5D7770),
                    ),
                    filled: true,
                    fillColor: theme.cardColor.withValues(alpha: 0.92),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                for (final entry in groupedDoa.entries) ...[
                  _CategoryHeader(title: entry.key, count: entry.value.length),
                  const SizedBox(height: 8),
                  for (final doa in entry.value) ...[
                    _DoaListItem(doa: doa),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 4),
                ],
                if (doaList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Doa tidak ditemukan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final int count;

  const _CategoryHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF08745F),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count doa',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoaListItem extends StatelessWidget {
  final DoaModel doa;

  const _DoaListItem({required this.doa});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      collapsedBackgroundColor: cardColor.withValues(alpha: 0.88),
      backgroundColor: cardColor,
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: const Color(0xFF08745F),
      collapsedIconColor: const Color(0xFF08745F),
      title: Text(
        doa.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: titleColor,
          fontSize: 14,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        doa.category,
        style: const TextStyle(
          color: Color(0xFF5D7770),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            doa.arabic,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00A783),
              fontSize: 22,
              height: 1.9,
              fontWeight: FontWeight.w500,
              fontFamily: 'serif',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '"${doa.translation}"',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF08745F),
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (doa.source.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            doa.source,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5D7770),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
