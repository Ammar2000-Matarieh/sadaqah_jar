import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/api/custom_api_services.dart';

class QuranController extends ChangeNotifier {
  final CustomApiServices _service = CustomApiServices();

  List<dynamic> _surahs = [];
  bool _isLoading = false;

  List<dynamic> get surahs => _surahs;
  bool get isLoading => _isLoading;

  Future<void> getSurahs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _surahs = await _service.fetchSurahs();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
