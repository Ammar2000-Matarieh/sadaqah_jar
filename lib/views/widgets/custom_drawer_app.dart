import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/views/about_screen.dart';
import 'package:sadqah_jariyah_app/views/privacy_polices.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_drawer_footer.dart';
import 'package:sadqah_jariyah_app/views/widgets/rate_app.dart';

class CustomDrawerApp extends StatelessWidget {
  const CustomDrawerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(theme: theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  DrawerItem(
                    icon: Icons.menu_book_rounded,
                    label: 'القرآن الكريم',
                    onTap: () => _navigateToTab(context, 0),
                  ),
                  DrawerItem(
                    icon: Icons.auto_stories_rounded,
                    label: 'الأحاديث',
                    onTap: () => _navigateToTab(context, 1),
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  DrawerItem(
                    icon: Icons.star_rate_rounded,
                    label: 'تقييم التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      RateAppBottomSheet.show(context);
                    },
                  ),
                  DrawerItem(
                    icon: Icons.privacy_tip_rounded,
                    label: 'سياسة الخصوصية',
                    onTap: () => _pushPage(context, const PrivacyPolicyPage()),
                  ),
                  DrawerItem(
                    icon: Icons.info_rounded,
                    label: 'عن التطبيق',
                    onTap: () => _pushPage(context, const AboutScreen()),
                  ),
                ],
              ),
            ),
            DrawerFooter(),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    Navigator.pop(context);
    context.read<BottomNavController>().changeNavIndex(index);
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }
}

class DrawerHeader extends StatelessWidget {
  const DrawerHeader({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.favorite_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text(
            'صدقة جارية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'نسأل الله القبول',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor, size: 24),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
