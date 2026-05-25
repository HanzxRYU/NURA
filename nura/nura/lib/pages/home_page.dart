/// Halaman Beranda: ringkasan jadwal shalat, tanggal Hijriyah, dan Doa harian.
///
/// Mengambil data dari `PrayerProvider` dan menampilkan beberapa komponen.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/prayer_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/daily_doa_card.dart';
import '../widgets/hijri_card.dart';
import '../widgets/prayer_card.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onOpenPrayer;
  final VoidCallback? onOpenDoa;

  const HomePage({
    super.key,
    this.onOpenPrayer,
    this.onOpenDoa,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PrayerProvider>().fetchPrayerData();
    });
  }

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
            if (provider.isLoading || provider.data == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF08745F),
                ),
              );
            }

            final dailyDoa = provider.dailyDoa;

            final dateData = provider.data!['date'];
            final hijri = Map<String, dynamic>.from(dateData['hijri']);
            final gregorian = Map<String, dynamic>.from(
              dateData['gregorian'],
            );
            final timings = Map<String, dynamic>.from(
              provider.data!['timings'],
            );
            final monthData = Map<String, dynamic>.from(hijri['month']);
            final hijriMonthNumber = int.tryParse(
                  monthData['number']?.toString() ?? '',
                ) ??
                1;
            final hijriDay = int.tryParse(hijri['day']?.toString() ?? '') ?? 1;
            final hijriYear = int.tryParse(hijri['year']?.toString() ?? '') ??
                DateTime.now().year;
            final nextHijriMonth = _nextHijriMonth(
              hijriMonthNumber,
              hijriYear,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 112),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/nura.png',
                        width: 73,
                        fit: BoxFit.contain,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return IconButton(
                                tooltip: themeProvider.isDarkMode
                                    ? 'Mode terang'
                                    : 'Mode gelap',
                                padding: const EdgeInsets.only(top: 6),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: themeProvider.toggleTheme,
                                icon: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: const Color(0xFF08745F),
                                  size: 24,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.only(top: 6, right: 5),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            visualDensity: VisualDensity.compact,
                            onPressed: _openCalendarPage,
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              color: Color(0xFF08745F),
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Assalamualaikum,',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'User \u{1F44B}',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 19,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatHijriDate(hijri),
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrayerCard(
                    timings: timings,
                    location: provider.selectedLocation.displayName,
                    onOpenSchedule: _openPrayerPage,
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Kalender Hijriyah',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 9),
                  HijriCard(
                    day: hijri['day']?.toString() ?? '',
                    monthName: _hijriMonthName(
                      monthData['en']?.toString() ?? '',
                    ),
                    year: hijri['year']?.toString() ?? '',
                    gregorianDate: _formatGregorianDate(gregorian),
                    upcomingDate:
                        '1 ${nextHijriMonth.name}\n${nextHijriMonth.year} H',
                    upcomingSubtitle:
                        '${_daysUntilNextHijriMonth(hijriDay)} Hari Lagi',
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DOA PILIHAN HARI INI',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: _openDoaPage,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5D7770),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dailyDoa != null) DailyDoaCard(doa: dailyDoa),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatHijriDate(Map<String, dynamic> hijri) {
    final day = hijri['day']?.toString() ?? '';
    final year = hijri['year']?.toString() ?? '';
    final monthData = Map<String, dynamic>.from(hijri['month']);
    final monthName = _hijriMonthName(monthData['en']?.toString() ?? '');

    return '$day $monthName $year H';
  }

  String _formatGregorianDate(Map<String, dynamic> gregorian) {
    final weekday = Map<String, dynamic>.from(gregorian['weekday']);
    final month = Map<String, dynamic>.from(gregorian['month']);
    final day = gregorian['day']?.toString() ?? '';
    final year = gregorian['year']?.toString() ?? '';
    final weekdayName = _weekdayName(weekday['en']?.toString() ?? '');
    final monthName = _gregorianMonthName(month['en']?.toString() ?? '');

    return '$weekdayName $day $monthName $year';
  }

  _UpcomingHijriMonth _nextHijriMonth(int monthNumber, int year) {
    final nextMonthNumber = monthNumber == 12 ? 1 : monthNumber + 1;
    final nextYear = monthNumber == 12 ? year + 1 : year;

    return _UpcomingHijriMonth(
      name: _hijriMonthNameByNumber(nextMonthNumber),
      year: nextYear,
    );
  }

  int _daysUntilNextHijriMonth(int day) {
    return (30 - day + 1).clamp(1, 30).toInt();
  }

  void _openCalendarPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CalendarPage(),
      ),
    );
  }

  void _openPrayerPage() {
    widget.onOpenPrayer?.call();
  }

  void _openDoaPage() {
    widget.onOpenDoa?.call();
  }

  String _hijriMonthName(String apiName) {
    const monthNames = {
      'Muharram': 'Muharram',
      'Safar': 'Safar',
      'Rabi al-awwal': 'Rabiul Awal',
      'Rabi al-thani': 'Rabiul Akhir',
      'Jumada al-awwal': 'Jumadil Awal',
      'Jumada al-thani': 'Jumadil Akhir',
      'Rajab': 'Rajab',
      'Shaban': 'Syaban',
      'Ramadan': 'Ramadhan',
      'Shawwal': 'Syawal',
      'Dhu al-Qadah': "Dzulqa'dah",
      'Dhu al-Hijjah': 'Dzulhijjah',
    };

    return monthNames[apiName] ?? apiName;
  }

  String _hijriMonthNameByNumber(int monthNumber) {
    const monthNames = {
      1: 'Muharram',
      2: 'Safar',
      3: 'Rabiul Awal',
      4: 'Rabiul Akhir',
      5: 'Jumadil Awal',
      6: 'Jumadil Akhir',
      7: 'Rajab',
      8: 'Syaban',
      9: 'Ramadhan',
      10: 'Syawal',
      11: "Dzulqa'dah",
      12: 'Dzulhijjah',
    };

    return monthNames[monthNumber] ?? '';
  }

  String _weekdayName(String apiName) {
    const weekdays = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };

    return weekdays[apiName] ?? apiName;
  }

  String _gregorianMonthName(String apiName) {
    const months = {
      'January': 'januari',
      'February': 'februari',
      'March': 'maret',
      'April': 'april',
      'May': 'mei',
      'June': 'juni',
      'July': 'juli',
      'August': 'agustus',
      'September': 'september',
      'October': 'oktober',
      'November': 'november',
      'December': 'desember',
    };

    return months[apiName] ?? apiName.toLowerCase();
  }
}

class _UpcomingHijriMonth {
  final String name;
  final int year;

  const _UpcomingHijriMonth({
    required this.name,
    required this.year,
  });
}
