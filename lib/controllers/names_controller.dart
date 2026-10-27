import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sadqah_jariyah_app/model/allah_name.dart';

class NamesController extends ChangeNotifier {
  static const _url = 'https://api.islamic.app/v1/asma-al-husna';

  List<AllahName> _all = [];
  String _query = '';
  bool isLoading = false;
  bool hasError = false;

  List<AllahName> get names {
    if (_query.isEmpty) return _all;
    final q = _normalize(_query);
    return _all.where((n) => _normalize(n.name).contains(q)).toList();
  }

  Future<void> load() async {
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      final res = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final list = (decoded is List ? decoded : decoded['data']) as List;
      _all = list
          .map((e) => AllahName.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String value) {
    _query = value.trim();
    notifyListeners();
  }

  /// يشيل التشكيل و"ال" ويوحّد الألف والهاء/التاء المربوطة
  /// عشان "رحمن" أو "الرحمن" يطلعوا "الرَّحْمَنُ"
  static String _normalize(String s) {
    return s
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceFirst(RegExp(r'^ال'), '');
  }
}
