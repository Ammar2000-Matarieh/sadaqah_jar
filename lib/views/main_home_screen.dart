import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_body_nav_bar.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_bottom_nav_widget.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_drawer_app.dart';

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
        drawer: CustomDrawerApp(),
        body: CustomBody(),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}
