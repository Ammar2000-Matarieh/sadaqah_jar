import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_about_us_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: const Text(
          'عن التطبيق',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        // backgroundColor: AppColors.primaryColor,
        backgroundColor: context.palette.topBar,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: CustomAboutUsWidget(),
    );
  }
}
