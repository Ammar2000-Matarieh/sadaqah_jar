import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  static const _items = <({IconData icon, IconData selected, String label})>[
    (
      icon: Icons.menu_book_outlined,
      selected: Icons.menu_book_rounded,
      label: 'القرآن',
    ),
    (
      icon: Icons.auto_stories_outlined,
      selected: Icons.auto_stories_rounded,
      label: 'الأحاديث',
    ),
    (
      icon: Icons.touch_app_outlined,
      selected: Icons.touch_app,
      label: 'المسبحة',
    ),
    (
      icon: Icons.access_time_outlined,
      selected: Icons.access_time_filled,
      label: 'الصلاة',
    ),
    (
      icon: Icons.info_outline_rounded,
      selected: Icons.info_rounded,
      label: 'اذكار',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final controller = context.watch<BottomNavController>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.bottomBar,
        border: Border(top: BorderSide(color: p.border, width: 0.8)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: p.bottomBar,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          height: 70,
          indicatorColor: p.accent.withValues(alpha: 0.14),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected ? p.accent : p.textSecondary,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? p.accent : p.textSecondary,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: controller.currentIndex,
          onDestinationSelected: controller.changeNavIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final i in _items)
              NavigationDestination(
                icon: Icon(i.icon),
                selectedIcon: Icon(i.selected),
                label: i.label,
              ),
          ],
        ),
      ),
    );
  }
}

// class CustomBottomNavBar extends StatelessWidget {
//   const CustomBottomNavBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<BottomNavController>(
//       builder: (context, value, child) {
//         return Container(
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.04),
//                 blurRadius: 20,
//                 offset: const Offset(0, -4),
//               ),
//             ],
//           ),
//           child: NavigationBar(
//             selectedIndex: value.currentIndex,
//             onDestinationSelected: (index) => value.changeNavIndex(index),
//             // backgroundColor: Colors.white,
//             backgroundColor: context.palette.background,
//             indicatorColor: AppColors.primaryColor.withValues(alpha: 0.12),
//             height: 70,
//             labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//             destinations: [
//               NavigationDestination(
//                 icon: Icon(
//                   Icons.menu_book_outlined,
//                   // color: AppColors.primaryColor,
//                   color: context.palette.textPrimary, //
//                 ),
//                 selectedIcon: Icon(
//                   Icons.menu_book_rounded,
//                   color: context.palette.topBar,
//                 ),
//                 label: 'القرآن',

//               ),
//               NavigationDestination(
//                 icon: Icon(
//                   Icons.auto_stories_outlined,
//                   color: context.palette.textPrimary,
//                 ),
//                 selectedIcon: Icon(
//                   Icons.auto_stories_rounded,
//                   color: context.palette.topBar,
//                 ),
//                 label: 'الأحاديث',
//               ),
//               NavigationDestination(
//                 icon: Icon(
//                   Icons.touch_app_outlined,
//                   color: context.palette.textPrimary,
//                 ),
//                 selectedIcon: Icon(
//                   Icons.touch_app,
//                   color: context.palette.topBar,
//                 ),
//                 label: 'المسبحة',
//               ),
//               NavigationDestination(
//                 icon: Icon(
//                   Icons.access_time_outlined,
//                   color: context.palette.textPrimary,
//                 ),
//                 selectedIcon: Icon(
//                   Icons.access_time_filled,
//                   color: context.palette.topBar,
//                 ),
//                 label: 'الصلاة',
//               ),

//               NavigationDestination(
//                 icon: Icon(
//                   Icons.info_outline_rounded,
//                   color: context.palette.textPrimary,
//                 ),
//                 selectedIcon: Icon(
//                   Icons.info_rounded,
//                   color: context.palette.topBar,
//                 ),
//                 label: 'القبلة',
//               ),
//               //AzkarScreen
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
