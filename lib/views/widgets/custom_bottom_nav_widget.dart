import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavController>(
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
                  color: AppColors.primaryColor,
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
                label: 'اذكار',
              ),
              //AzkarScreen
            ],
          ),
        );
      },
    );
  }
}
