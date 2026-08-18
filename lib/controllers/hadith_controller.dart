import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/api/custom_api_services.dart';

class HadithController extends ChangeNotifier {
  final CustomApiServices _apiServices = CustomApiServices();

  static const String selectedEdition = 'ara-abudawud';

  bool isLoading = false;
  bool hasError = false;
  List<Map<String, String>> hadiths = [];

  Future<void> getHadiths() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final data = await _apiServices.fetchHadithBook(selectedEdition);

      final mapped = data
          .map<Map<String, String>>(
            (h) => {
              "id": (h['hadithnumber'] ?? h['arabicnumber'] ?? '').toString(),
              "text": (h['text'] ?? '').toString(),
            },
          )
          .where((h) => h['text']!.trim().isNotEmpty)
          .toList();

      if (mapped.isEmpty) throw Exception('لا توجد بيانات');

      hadiths = mapped;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ HADITH ERROR: $e');
      isLoading = false;
      hasError = true;
      notifyListeners();
    }
  }
}
