import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';

class CustomItem extends StatelessWidget {
  final String text;
  const CustomItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
