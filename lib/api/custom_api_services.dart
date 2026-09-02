import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sadqah_jariyah_app/api/error.dart';
import 'package:sadqah_jariyah_app/model/azkar_categoriea.dart';
import 'package:sadqah_jariyah_app/model/reciter.dart';
import 'package:sadqah_jariyah_app/model/surah.dart';
import 'package:sadqah_jariyah_app/model/surah_response.dart';
import 'package:sadqah_jariyah_app/utils/enums/azkar_enum.dart';

class CustomApiServices {
  static const String baseApiHost = "https://api.alquran.cloud/v1";
  static const String baseUrl = "$baseApiHost/surah";
  static const String baseUrlAnan2 = "https://5etme.com";
  static const String hadithBaseUrl =
      "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1";

  static const String baseUrlAzkar = 'https://ahegazy.github.io/muslimKit/json';

  static const Map<AzkarType, String> _endpoints = {
    AzkarType.morning: 'azkar_sabah.json',
    AzkarType.evening: 'azkar_massa.json',
  };

  static Future<AzkarCategory> fetch(AzkarType type) async {
    final fileName = _endpoints[type]!;
    final uri = Uri.parse('$baseUrlAzkar/$fileName');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw AzkarException(
          'تعذّر تحميل الأذكار (رمز الخطأ: ${response.statusCode})',
        );
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return AzkarCategory.fromJson(decoded as Map<String, dynamic>);
    } on AzkarException {
      rethrow;
    } catch (_) {
      throw AzkarException('تحقق من اتصال الإنترنت وحاول مرة أخرى');
    }
  }

  Future<List<Reciter>> fetchReciters() async {
    final response = await http.get(
      Uri.parse(
        "$baseApiHost/edition?format=audio&language=ar&type=versebyverse",
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List<dynamic>)
          .map((e) => Reciter.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load reciters');
    }
  }

  Future<SurahWithAyahs> fetchSurahAudio(
    int surahNumber,
    String editionId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$surahNumber/$editionId"),
    );

    if (response.statusCode == 200) {
      final json_ = json.decode(response.body);
      return SurahAudioResponse.fromJson(json_).data;
    } else {
      throw Exception('Failed to load surah audio');
    }
  }

  Future<List<Surah>> fetchSurahs() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List<dynamic>)
          .map((e) => Surah.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  Future<List<dynamic>> fetchHadithEditions() async {
    final response = await http.get(Uri.parse('$hadithBaseUrl/editions.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['hadiths'];
    } else {
      throw Exception('Failed to load hadith editions');
    }
  }

  Future<List<dynamic>> fetchHadithBook(String editionName) async {
    final response = await http.get(
      Uri.parse('$hadithBaseUrl/editions/$editionName.json'),
    );
    debugPrint('STATUS CODE: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['hadiths'];
    } else {
      throw Exception(
        'Failed to load hadith book: $editionName (status: ${response.statusCode})',
      );
    }
  }

  Future<Map<String, dynamic>> fetchHadithByNumber({
    required String editionName,
    required int number,
  }) async {
    final response = await http.get(
      Uri.parse('$hadithBaseUrl/editions/$editionName/$number.json'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['hadiths'][0];
    } else {
      throw Exception('Failed to load hadith #$number from $editionName');
    }
  }

  Future<Map<String, dynamic>> fetchRandomHadith(
    String editionName,
    int totalHadiths,
  ) async {
    final randomNumber = Random().nextInt(totalHadiths) + 1;
    return fetchHadithByNumber(editionName: editionName, number: randomNumber);
  }

  Future<List<dynamic>> fetchSurahDetails(int surahNumber) async {
    final response = await http.get(Uri.parse("$baseUrl/$surahNumber"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['ayahs'] as List<dynamic>;
    } else {
      throw Exception('Failed to load surah details');
    }
  }

  /// جلب روابط الصوت لقارئ معيّن
  Future<List<String>> fetchSurahAudioUrls(
    int surahNumber,
    String editionId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$surahNumber/$editionId"),
    );

    if (response.statusCode != 200) {
      throw Exception('القارئ غير مدعوم لهذه السورة');
    }

    final data = json.decode(response.body);
    final List audioAyahs = data['data']['ayahs'];

    return audioAyahs
        .map((a) => a['audio'] as String?)
        .where((u) => u != null && u.isNotEmpty)
        .cast<String>()
        .toList();
  }
}
