// models/reciter.dart (لـ fetchReciters - نفس شكل Edition)

class Reciter {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;

  Reciter({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      identifier: json['identifier'] as String,
      language: json['language'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      format: json['format'] as String,
      type: json['type'] as String,
    );
  }
}
