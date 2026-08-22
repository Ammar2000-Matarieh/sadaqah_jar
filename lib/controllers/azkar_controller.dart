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

  late List<int> counters = List.filled(azkarList.length, 0);

  void incrementCounter(int index) {
    counters[index]++;
    notifyListeners();
  }

  void resetCounter(int index) {
    counters[index] = 0;
    notifyListeners();
  }

  void resetAll() {
    counters = List.filled(azkarList.length, 0);
    notifyListeners();
  }

  void azkarIndexCalculate() {
    zikrIndex = (zikrIndex + 1) % azkarList.length;
    counter = 0;
    notifyListeners();
  }
}
