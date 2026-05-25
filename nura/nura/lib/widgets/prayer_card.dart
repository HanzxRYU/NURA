/// Kartu utama untuk menampilkan waktu shalat berikutnya, jam sekarang,
/// dan pengingat waktu menuju adzan.
///
/// Widget ini berisi logika visual dan kecil untuk menghitung waktu selanjutnya.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class PrayerCard extends StatefulWidget {
  final Map<String, dynamic> timings;
  final String location;
  final VoidCallback? onOpenSchedule;

  const PrayerCard({
    super.key,
    required this.timings,
    this.location = 'Rumpin Bogor',
    this.onOpenSchedule,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  static const List<_PrayerInfo> _prayers = [
    _PrayerInfo('Fajr', 'SUBUH'),
    _PrayerInfo('Dhuhr', 'DZUHUR'),
    _PrayerInfo('Asr', 'ASHAR'),
    _PrayerInfo('Maghrib', 'MAGHRIB'),
    _PrayerInfo('Isha', 'ISYA'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _nextPrayer();
    final remaining = nextPrayer.time.difference(_now);
    final remainingMinutes = math.max(0, remaining.inMinutes + 1);
    final remainingText = _formatRemainingTime(remainingMinutes);
    final theme = _PrayerVisualTheme.forPrayer(nextPrayer.label);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 228),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradient,
          stops: [0, 0.58, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 8,
            child: Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1.1,
                ),
              ),
              child: PrayerTimeIcon(prayerLabel: nextPrayer.label, size: 48),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.36)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3D467),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      nextPrayer.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Text(
                _formatClock(nextPrayer.time),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  height: 0.95,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              Container(
                width: 118,
                height: 2,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                color: const Color(0xFFE3D467),
              ),
              Text(
                '$remainingText Lagi Menuju Adzan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_formatClock(nextPrayer.time)} ${widget.location}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: widget.onOpenSchedule,
                child: Container(
                  height: 31,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.64)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Lihat Jadwal Shalat Lengkap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _NextPrayer _nextPrayer() {
    final parsedPrayers = _prayers.map((prayer) {
      final rawTime = widget.timings[prayer.apiKey]?.toString() ?? '00:00';
      return _NextPrayer(label: prayer.label, time: _timeForToday(rawTime));
    }).toList();

    for (final prayer in parsedPrayers) {
      if (prayer.time.isAfter(_now)) {
        return prayer;
      }
    }

    final tomorrowFajr = parsedPrayers.first.time.add(const Duration(days: 1));
    return _NextPrayer(label: parsedPrayers.first.label, time: tomorrowFajr);
  }

  DateTime _timeForToday(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    final hour = int.tryParse(match?.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match?.group(2) ?? '') ?? 0;

    return DateTime(_now.year, _now.month, _now.day, hour, minute);
  }

  String _formatClock(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatRemainingTime(int minutes) {
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

class PrayerTimeIcon extends StatelessWidget {
  final String prayerLabel;
  final double size;

  const PrayerTimeIcon({
    super.key,
    required this.prayerLabel,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconForPrayer(prayerLabel),
      color: Colors.white,
      size: size,
    );
  }

  IconData _iconForPrayer(String label) {
    switch (label) {
      case 'SUBUH':
        return Icons.nights_stay_outlined;
      case 'DZUHUR':
        return Icons.wb_sunny_outlined;
      case 'ASHAR':
        return Icons.wb_twilight_outlined;
      case 'MAGHRIB':
        return Icons.brightness_4_outlined;
      case 'ISYA':
        return Icons.dark_mode_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}

class _PrayerVisualTheme {
  final List<Color> gradient;
  final Color shadowColor;

  const _PrayerVisualTheme({required this.gradient, required this.shadowColor});

  factory _PrayerVisualTheme.forPrayer(String label) {
    switch (label) {
      case 'SUBUH':
        return const _PrayerVisualTheme(
          gradient: [Color(0xFF29466F), Color(0xFF08745F), Color(0xFF18BE9A)],
          shadowColor: Color(0xFF29466F),
        );
      case 'DZUHUR':
        return const _PrayerVisualTheme(
          gradient: [Color(0xFF08745F), Color(0xFF0B7C64), Color(0xFF18BE9A)],
          shadowColor: Color(0xFF08745F),
        );
      case 'ASHAR':
        return const _PrayerVisualTheme(
          gradient: [Color(0xFF0A6E66), Color(0xFF0F8B75), Color(0xFFD5A84C)],
          shadowColor: Color(0xFF0A6E66),
        );
      case 'MAGHRIB':
        return const _PrayerVisualTheme(
          gradient: [Color(0xFF31506B), Color(0xFF946342), Color(0xFFE0B65B)],
          shadowColor: Color(0xFF31506B),
        );
      case 'ISYA':
        return const _PrayerVisualTheme(
          gradient: [Color(0xFF18304C), Color(0xFF275A5C), Color(0xFF0C7B67)],
          shadowColor: Color(0xFF18304C),
        );
      default:
        return const _PrayerVisualTheme(
          gradient: [Color(0xFF08745F), Color(0xFF0B7C64), Color(0xFF18BE9A)],
          shadowColor: Color(0xFF08745F),
        );
    }
  }
}

class _PrayerInfo {
  final String apiKey;
  final String label;

  const _PrayerInfo(this.apiKey, this.label);
}

class _NextPrayer {
  final String label;
  final DateTime time;

  const _NextPrayer({required this.label, required this.time});
}
