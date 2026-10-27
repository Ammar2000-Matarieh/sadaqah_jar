import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/hadith_controller.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_body_hadith.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HadithController>(context, listen: false).getHadiths();
    });

    return Scaffold(
      backgroundColor: context.palette.background,
      body: CustomHadithBody(),
    );
  }
}
