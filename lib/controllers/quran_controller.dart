import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/api/custom_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranController extends ChangeNotifier {
  final CustomApiServices _service = CustomApiServices();
  static const String _reciterPrefsKey = 'selected_reciter';

  List<dynamic> _surahs = [];
  List<dynamic> _reciters = [];
  String _selectedReciter = 'ar.alafasy';
  bool _isLoading = false;
  bool _isRecitersLoading = false;
  String? _recitersError;

  List<dynamic> get surahs => _surahs;
  List<dynamic> get reciters => _reciters;
  String get selectedReciter => _selectedReciter;
  bool get isLoading => _isLoading;
  bool get isRecitersLoading => _isRecitersLoading;
  String? get recitersError => _recitersError;

  QuranController() {
    _loadSavedReciter();
  }

  Future<void> _loadSavedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_reciterPrefsKey);
    if (saved != null) {
      _selectedReciter = saved;
      notifyListeners();
    }
  }

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

  Future<void> getReciters() async {
    _isRecitersLoading = true;
    _recitersError = null;
    notifyListeners();
    try {
      _reciters = await _service.fetchReciters();
    } catch (e) {
      _recitersError = 'تعذر تحميل قائمة القراء';
      debugPrint("Error: $e");
    } finally {
      _isRecitersLoading = false;
      notifyListeners();
    }
  }

  Future<void> setReciter(String identifier) async {
    _selectedReciter = identifier;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterPrefsKey, identifier);
  }
}
