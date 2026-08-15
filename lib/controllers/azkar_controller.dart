import 'package:flutter/cupertino.dart';

class AzkarController extends ChangeNotifier {
  int counter = 0;
  int zikrIndex = 0;

  final List<String> azkarList = [
    "سبحان الله وبحمده",
    "أستغفر الله وأتوب إليه",
    "لا إله إلا الله وحده لا شريك له",
    "اللهم صلِّ وسلم على نبينا محمد",
    "الحمد لله رب العالمين",
  ];

  void azkarIndexCalculate(int zikrIndex) {
    zikrIndex = (zikrIndex + 1) % azkarList.length;
    counter = 0;
    notifyListeners();
  }
}
