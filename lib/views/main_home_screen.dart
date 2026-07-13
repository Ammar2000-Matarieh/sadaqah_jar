import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/views/about_screen.dart';
import 'package:sadqah_jariyah_app/views/azkar_screen.dart';
import 'package:sadqah_jariyah_app/views/hadith.dart';
import 'package:sadqah_jariyah_app/views/prayer_times_screen.dart';
import 'package:sadqah_jariyah_app/views/quran_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const QuranPage(),
    const HadithPage(),
    const AzkarPage(),
    const PrayerTimesScreen(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF0F4C43).withValues(alpha: 0.12),
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined, color: Color(0xFF556B67)),
                selectedIcon: Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF0F4C43),
                ),
                label: 'القرآن',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.auto_stories_outlined,
                  color: Color(0xFF556B67),
                ),
                selectedIcon: Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFF0F4C43),
                ),
                label: 'الأحاديث',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.fingerprint_outlined,
                  color: Color(0xFF556B67),
                ),
                selectedIcon: Icon(
                  Icons.fingerprint_rounded,
                  color: Color(0xFF0F4C43),
                ),
                label: 'المسبحة',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons.fingerprint_outlined,
                  color: Color(0xFF556B67),
                ),
                selectedIcon: Icon(
                  Icons.fingerprint_rounded,
                  color: Color(0xFF0F4C43),
                ),
                label: 'مواقيت الصلاة',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFF556B67),
                ),
                selectedIcon: Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF0F4C43),
                ),
                label: 'عن التطبيق',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
