import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final selectedHijri = _HijriDate.fromGregorian(_selectedDate);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFB8D8D0);

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF08745F),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Kalender',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DateSummary(
              selectedDate: _selectedDate,
              selectedHijri: selectedHijri,
            ),
            const SizedBox(height: 16),
            _CalendarPanel(
              visibleMonth: _visibleMonth,
              selectedDate: _selectedDate,
              onPreviousMonth: () => setState(() {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month - 1,
                );
              }),
              onNextMonth: () => setState(() {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month + 1,
                );
              }),
              onSelectDate: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 16),
            _HijriMonthPanel(
              selectedHijri: selectedHijri,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSummary extends StatelessWidget {
  final DateTime selectedDate;
  final _HijriDate selectedHijri;

  const _DateSummary({
    required this.selectedDate,
    required this.selectedHijri,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.brightness == Brightness.dark
        ? const Color(0xFFA8C6BE)
        : const Color(0xFF71817C);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F8F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedDate.day.toString(),
                  style: const TextStyle(
                    color: Color(0xFF08745F),
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weekdayName(selectedDate.weekday),
                  style: const TextStyle(
                    color: Color(0xFF5D7770),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatGregorianDate(selectedDate),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  selectedHijri.formatted,
                  style: const TextStyle(
                    color: Color(0xFF00A783),
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tanggal Hijriyah bersifat perkiraan.',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarPanel extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  const _CalendarPanel({
    required this.visibleMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final leadingEmptyDays = firstDay.weekday - 1;
    final totalCells = leadingEmptyDays + daysInMonth;
    final cellCount = totalCells <= 35 ? 35 : 42;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF08745F),
              ),
              Expanded(
                child: Text(
                  '${_gregorianMonthName(visibleMonth.month)} ${visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF08745F),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              _WeekdayLabel('Sen'),
              _WeekdayLabel('Sel'),
              _WeekdayLabel('Rab'),
              _WeekdayLabel('Kam'),
              _WeekdayLabel('Jum'),
              _WeekdayLabel('Sab'),
              _WeekdayLabel('Min'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingEmptyDays + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                visibleMonth.year,
                visibleMonth.month,
                dayNumber,
              );
              final hijri = _HijriDate.fromGregorian(date);
              final isSelected = _isSameDate(date, selectedDate);
              final isToday = _isSameDate(date, DateTime.now());

              return _CalendarDayTile(
                date: date,
                hijriDay: hijri.day,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => onSelectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  final DateTime date;
  final int hijriDay;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _CalendarDayTile({
    required this.date,
    required this.hijriDay,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? const Color(0xFF08745F)
        : isToday
            ? const Color(0xFFE7F8F3)
            : isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFFAFCFB);
    final primaryColor =
        isSelected ? Colors.white : theme.colorScheme.onSurface;
    final secondaryColor = isSelected
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFF00A783);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF08745F)
                : const Color(0xFFDFECE8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$hijriDay H',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 9,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HijriMonthPanel extends StatelessWidget {
  final _HijriDate selectedHijri;

  const _HijriMonthPanel({
    required this.selectedHijri,
  });

  @override
  Widget build(BuildContext context) {
    final remainingDays = (30 - selectedHijri.day).clamp(0, 29);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08745F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.nights_stay_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kalender Hijriyah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedHijri.monthName} ${selectedHijri.year} H',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remainingDays == 0
                      ? 'Perkiraan akhir bulan Hijriyah.'
                      : 'Sekitar $remainingDays hari menuju bulan berikutnya.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF5D7770),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HijriDate {
  final int day;
  final int month;
  final int year;

  const _HijriDate({
    required this.day,
    required this.month,
    required this.year,
  });

  String get monthName => _hijriMonthName(month);

  String get formatted => '$day $monthName $year H';

  factory _HijriDate.fromGregorian(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final a = (14 - m) ~/ 12;
    final adjustedYear = y + 4800 - a;
    final adjustedMonth = m + 12 * a - 3;
    final julianDay = d +
        ((153 * adjustedMonth + 2) ~/ 5) +
        365 * adjustedYear +
        (adjustedYear ~/ 4) -
        (adjustedYear ~/ 100) +
        (adjustedYear ~/ 400) -
        32045;

    var l = julianDay - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;

    return _HijriDate(day: day, month: month, year: year);
  }
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatGregorianDate(DateTime date) {
  return '${_weekdayName(date.weekday)}, ${date.day} '
      '${_gregorianMonthName(date.month)} ${date.year}';
}

String _weekdayName(int weekday) {
  const weekdays = {
    DateTime.monday: 'Senin',
    DateTime.tuesday: 'Selasa',
    DateTime.wednesday: 'Rabu',
    DateTime.thursday: 'Kamis',
    DateTime.friday: 'Jumat',
    DateTime.saturday: 'Sabtu',
    DateTime.sunday: 'Minggu',
  };

  return weekdays[weekday] ?? '';
}

String _gregorianMonthName(int month) {
  const months = {
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };

  return months[month] ?? '';
}

String _hijriMonthName(int month) {
  const months = {
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

  return months[month] ?? '';
}
