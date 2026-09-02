import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';

class CustomBody extends StatelessWidget {
  const CustomBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavController>(
      builder: (context, value, child) {
        return IndexedStack(index: value.currentIndex, children: value.screens);
      },
    );
  }
}
