import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<BottomNavController>(
            builder: (context, value, child) {
              return Text(
                value.titles[value.currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              );
            },
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        drawer: Drawer(
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
                    context.read<BottomNavController>().changeNavIndex(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text('القرآن الكريم'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<BottomNavController>().changeNavIndex(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_stories),
                  title: const Text('الأحاديث'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<BottomNavController>().changeNavIndex(1);
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
        ),
        body: Consumer<BottomNavController>(
          builder: (context, value, child) {
            return IndexedStack(
              index: value.currentIndex,
              children: value.screens,
            );
          },
        ),
        bottomNavigationBar: Consumer<BottomNavController>(
          builder: (context, value, child) {
            return Container(
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
                selectedIndex: value.currentIndex,
                onDestinationSelected: (index) => value.changeNavIndex(index),
                backgroundColor: Colors.white,
                indicatorColor: AppColors.primaryColor.withValues(alpha: 0.12),
                height: 70,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.primaryColor,
                    ),
                    selectedIcon: Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primaryColor,
                    ),
                    label: 'القرآن',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.auto_stories_outlined,
                      color: AppColors.primaryColor,
                    ),
                    selectedIcon: Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFF0F4C43),
                    ),
                    label: 'الأحاديث',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.touch_app_outlined,
                      color: AppColors.primaryColor,
                    ),
                    selectedIcon: Icon(
                      Icons.touch_app,
                      color: AppColors.primaryColor,
                    ),
                    label: 'المسبحة',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.access_time_outlined,
                      color: AppColors.primaryColor,
                    ),
                    selectedIcon: Icon(
                      Icons.access_time_filled,
                      color: AppColors.primaryColor,
                    ),
                    label: 'الصلاة',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryColor,
                    ),
                    selectedIcon: Icon(
                      Icons.info_rounded,
                      color: AppColors.primaryColor,
                    ),
                    label: 'عن التطبيق',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
