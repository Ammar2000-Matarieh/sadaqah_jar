import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/views/about_screen.dart';
import 'package:sadqah_jariyah_app/views/azkar_screen.dart';
import 'package:sadqah_jariyah_app/views/hadith.dart';
import 'package:sadqah_jariyah_app/views/khitma_screen.dart';
import 'package:sadqah_jariyah_app/views/prayer_times_screen.dart';
import 'package:sadqah_jariyah_app/views/quran_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'القرآن الكريم',
    'الأحاديث النبوية',
    'المسبحة الإلكترونية',
    'مواقيت الصلاة',
    'عن التطبيق',
  ];

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
        appBar: AppBar(
          title: Text(
            _titles[_currentIndex],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF0F4C43),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F4C43), Color(0xFF18665B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        drawer: _buildDrawer(),
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
                icon: Icon(Icons.touch_app_outlined, color: Color(0xFF556B67)),
                selectedIcon: Icon(Icons.touch_app, color: Color(0xFF0F4C43)),
                label: 'المسبحة',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons.access_time_outlined,
                  color: Color(0xFF556B67),
                ),
                selectedIcon: Icon(
                  Icons.access_time_filled,
                  color: Color(0xFF0F4C43),
                ),
                label: 'الصلاة',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF556B67),
                ),
                selectedIcon: Icon(
                  Icons.info_rounded,
                  color: Color(0xFF0F4C43),
                ),
                label: 'عن التطبيق',
              ),

              // NavigationDestination(
              //   icon: Icon(
              //     Icons.volunteer_activism_outlined,
              //     color: Color(0xFF556B67),
              //   ),
              //   selectedIcon: Icon(
              //     Icons.volunteer_activism,
              //     color: Color(0xFF0F4C43),
              //   ),
              //   label: 'الختمات',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0F4C43)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.favorite, size: 30),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'صدقة جارية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'نسأل الله القبول',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('الرئيسية'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('القرآن الكريم'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),

            ListTile(
              leading: const Icon(Icons.auto_stories),
              title: const Text('الأحاديث'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),

            ListTile(
              leading: const Icon(Icons.volunteer_activism_outlined),
              title: const Text('الختمات'),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoDialogRoute(
                    builder: (context) => KhatmaScreen(
                      khatmaId: '1',
                      repository: MockKhatmaRepository(),
                    ),
                    context: context,
                  ),
                );
                // Navigator.pop(context);
                // setState(() => _currentIndex = 2);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('مشاركة التطبيق'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text('تقييم التطبيق'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('سياسة الخصوصية'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
