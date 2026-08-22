import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomApiServices {
  static const String baseApiHost = "https://api.alquran.cloud/v1";

  static const String baseUrl = "$baseApiHost/surah";

  static const String baseUrlAnan2 = "https://5etme.com";

  static const String hadithBaseUrl =
      "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1";

  Future<List<dynamic>> fetchReciters() async {
    final response = await http.get(
      Uri.parse(
        "$baseApiHost/edition?format=audio&language=ar&type=versebyverse",
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load reciters');
    }
  }

  Future<List<dynamic>> fetchSurahAudio(
    int surahNumber,
    String editionId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$surahNumber/$editionId"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['ayahs'];
    } else {
      throw Exception('Failed to load surah audio');
    }
  }

  Future<List<dynamic>> fetchSurahs() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
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
}
