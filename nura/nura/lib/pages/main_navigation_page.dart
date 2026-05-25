/// Halaman navigasi utama yang mengelola tab bottom navigation.
///
/// Menggunakan `IndexedStack` untuk mempertahankan state setiap halaman.
import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav_bar.dart';
import 'doa_page.dart';
import 'home_page.dart';
import 'prayer_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PrayerPage(),
      HomePage(
        onOpenPrayer: () {
          setState(() => _currentIndex = 0);
        },
        onOpenDoa: () {
          setState(() => _currentIndex = 2);
        },
      ),
      const DoaPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
