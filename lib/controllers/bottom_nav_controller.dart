import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/views/azkar.dart';
import 'package:sadqah_jariyah_app/views/azkar_screen.dart';
import 'package:sadqah_jariyah_app/views/hadith.dart';
import 'package:sadqah_jariyah_app/views/prayer_times_screen.dart';
import 'package:sadqah_jariyah_app/views/quran_screen.dart';

class BottomNavController extends ChangeNotifier {
  int currentIndex = 0;

  final List<String> titles = [
    'القرآن الكريم',
    'الأحاديث النبوية',
    'المسبحة الإلكترونية',
    'مواقيت الصلاة',
    'الاذكار',
  ];

  final List<Widget> screens = [
    const QuranScreen(),
    const HadithScreen(),
    const AzkarScreen(),
    const PrayerTimesScreen(),
    const AzkarScreenNew(),
  ];

  void changeNavIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
