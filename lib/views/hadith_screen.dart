import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/hadith_controller.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_body_hadith.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HadithController>(context, listen: false).getHadiths();
    });

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: CustomHadithBody(),
    );
  }
}
