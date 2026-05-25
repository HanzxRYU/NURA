/// Halaman jadwal shalat lengkap dan pencarian lokasi.
///
/// Menyediakan ringkasan waktu shalat hari ini dan alat pencarian lokasi.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/prayer_provider.dart';
import '../widgets/prayer_card.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  final TextEditingController _cityController = TextEditingController();

  static const List<_PrayerScheduleItem> _items = [
    _PrayerScheduleItem('Subuh', 'Fajr', 'SUBUH', Icons.nights_stay_outlined),
    _PrayerScheduleItem('Dzuhur', 'Dhuhr', 'DZUHUR', Icons.wb_sunny_outlined),
    _PrayerScheduleItem('Ashar', 'Asr', 'ASHAR', Icons.wb_twilight_outlined),
    _PrayerScheduleItem(
      'Maghrib',
      'Maghrib',
      'MAGHRIB',
      Icons.brightness_4_outlined,
    ),
    _PrayerScheduleItem('Isya', 'Isha', 'ISYA', Icons.dark_mode_outlined),
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground = isDark
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFB8D8D0);
    final titleColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Consumer<PrayerProvider>(
          builder: (context, provider, child) {
            if (provider.data == null) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF08745F)),
                );
              }

              return _PrayerLoadErrorView(
                message:
                    provider.prayerError ?? 'Jadwal shalat belum bisa dimuat.',
                onRetry: () {
                  context.read<PrayerProvider>().fetchPrayerData();
                },
              );
            }

            final timings = Map<String, dynamic>.from(
              provider.data!['timings'],
            );
            final nextPrayer = _nextPrayer(timings);
            final remainingMinutes = math.max(
              0,
              nextPrayer.time.difference(DateTime.now()).inMinutes + 1,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 112),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Jadwal Shalat',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 24,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xFF08745F),
                          strokeWidth: 2.4,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                _CitySearchField(
                  controller: _cityController,
                  isLoading: provider.isSearchingLocation,
                  errorText: provider.locationSearchError,
                  onSubmitted: () {
                    context.read<PrayerProvider>().searchLocation(
                      _cityController.text,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _NextPrayerSummary(
                  location: provider.selectedLocation,
                  nextPrayer: nextPrayer,
                  remainingText: _formatRemainingTime(remainingMinutes),
                ),
                const SizedBox(height: 16),
                Text(
                  'Waktu Hari Ini',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ..._items.map(
                  (item) => _PrayerTimeTile(
                    title: item.title,
                    time: timings[item.apiKey]?.toString() ?? '--:--',
                    icon: item.icon,
                    isActive: item.label == nextPrayer.label,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _NextPrayer _nextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final parsedPrayers = _items.map((item) {
      final rawTime = timings[item.apiKey]?.toString() ?? '00:00';
      return _NextPrayer(
        title: item.title,
        label: item.label,
        time: _timeForToday(rawTime, now),
      );
    }).toList();

    for (final prayer in parsedPrayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    final tomorrowFajr = parsedPrayers.first.time.add(const Duration(days: 1));
    return _NextPrayer(
      title: parsedPrayers.first.title,
      label: parsedPrayers.first.label,
      time: tomorrowFajr,
    );
  }

  static DateTime _timeForToday(String value, DateTime now) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    final hour = int.tryParse(match?.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match?.group(2) ?? '') ?? 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static String _formatClock(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _cleanTime(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) {
      return value;
    }

    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  static String _formatRemainingTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours Jam';
      }

      return '$hours Jam $remainingMinutes Menit';
    }

    return '$minutes Menit';
  }
}

class _PrayerLoadErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PrayerLoadErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFF08745F),
              size: 42,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2F4F48),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF08745F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitySearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onSubmitted;

  const _CitySearchField({
    required this.controller,
    required this.isLoading,
    required this.errorText,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final inputTextColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 5, 8, 5),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF08745F), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSubmitted(),
                  decoration: const InputDecoration(
                    hintText: 'Tulis kota, mis. Makkah',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    color: inputTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: isLoading ? null : onSubmitted,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Color(0xFF08745F),
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Icon(Icons.arrow_forward, color: Color(0xFF08745F)),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 7),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFF9B2C2C),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _NextPrayerSummary extends StatelessWidget {
  final PrayerLocation location;
  final _NextPrayer nextPrayer;
  final String remainingText;

  const _NextPrayerSummary({
    required this.location,
    required this.nextPrayer,
    required this.remainingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08745F), Color(0xFF0B7C64), Color(0xFF18BE9A)],
          stops: [0, 0.62, 1],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shalat Berikutnya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nextPrayer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_PrayerPageState._formatClock(nextPrayer.time)} - $remainingText lagi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.28)),
                  ),
                  child: Text(
                    location.coordinateText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 1.1,
              ),
            ),
            child: PrayerTimeIcon(prayerLabel: nextPrayer.label, size: 46),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeTile extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final bool isActive;

  const _PrayerTimeTile({
    required this.title,
    required this.time,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurface;
    final accentColor = isActive ? Colors.white : const Color(0xFF08745F);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 13, 16, 13),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF08745F) : theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.075 : 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.17)
                  : const Color(0xFFE7F8F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            _PrayerPageState._cleanTime(time),
            style: TextStyle(
              color: accentColor,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerScheduleItem {
  final String title;
  final String apiKey;
  final String label;
  final IconData icon;

  const _PrayerScheduleItem(this.title, this.apiKey, this.label, this.icon);
}

class _NextPrayer {
  final String title;
  final String label;
  final DateTime time;

  const _NextPrayer({
    required this.title,
    required this.label,
    required this.time,
  });
}
