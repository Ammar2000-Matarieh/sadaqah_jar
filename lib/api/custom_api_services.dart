import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomApiServices {
  static const String baseUrl = "https://api.alquran.cloud/v1/surah";

  static const String baseUrlAnan2 = "https://5etme.com";

  Future<List<dynamic>> fetchSurahs() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load surahs');
    }
  }
}
