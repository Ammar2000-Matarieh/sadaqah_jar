import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sadqah_jariyah_app/model/reciter.dart';
import 'package:sadqah_jariyah_app/model/surah.dart';
import 'package:sadqah_jariyah_app/model/surah_response.dart';

class CustomApiServices {
  static const String baseApiHost = "https://api.alquran.cloud/v1";
  static const String baseUrl = "$baseApiHost/surah";
  static const String baseUrlAnan2 = "https://5etme.com";
  static const String hadithBaseUrl =
      "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1";

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

  // Hadith methods تقدر تسيبها dynamic حاليًا أو نعملها موديل بجولة تانية إذا حابب
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
}
