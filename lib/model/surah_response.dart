// models/surah_response.dart

class SurahAudioResponse {
  final int code;
  final String status;
  final SurahWithAyahs data;

  SurahAudioResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  factory SurahAudioResponse.fromJson(Map<String, dynamic> json) {
    return SurahAudioResponse(
      code: json['code'] as int,
      status: json['status'] as String,
      data: SurahWithAyahs.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SurahWithAyahs {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<Ayah> ayahs;
  final Edition edition;

  SurahWithAyahs({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
    required this.edition,
  });

  factory SurahWithAyahs.fromJson(Map<String, dynamic> json) {
    return SurahWithAyahs(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      ayahs: (json['ayahs'] as List<dynamic>)
          .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
          .toList(),
      edition: Edition.fromJson(json['edition'] as Map<String, dynamic>),
    );
  }
}

class Ayah {
  final int number;
  final String? audio;
  final List<String> audioSecondary;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  Ayah({
    required this.number,
    required this.audio,
    required this.audioSecondary,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int,
      audio: json['audio'] as String?,
      audioSecondary: (json['audioSecondary'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      text: json['text'] as String? ?? '',
      numberInSurah: json['numberInSurah'] as int,
      juz: json['juz'] as int,
      manzil: json['manzil'] as int,
      page: json['page'] as int,
      ruku: json['ruku'] as int,
      hizbQuarter: json['hizbQuarter'] as int,
      sajda: json['sajda'] is Map, // true إذا فيها سجدة
    );
  }
}

class Edition {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String? direction;

  Edition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
  });

  factory Edition.fromJson(Map<String, dynamic> json) {
    return Edition(
      identifier: json['identifier'] as String,
      language: json['language'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      format: json['format'] as String,
      type: json['type'] as String,
      direction: json['direction'] as String?,
    );
  }
}
