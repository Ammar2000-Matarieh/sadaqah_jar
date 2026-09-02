import 'package:sadqah_jariyah_app/model/azkar.dart';

class AzkarCategory {
  final String title;
  final List<Azkar> content;

  const AzkarCategory({required this.title, required this.content});

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    final list = (json['content'] as List<dynamic>? ?? [])
        .map((e) => Azkar.fromJson(e as Map<String, dynamic>))
        .where((a) => a.text.isNotEmpty)
        .toList();

    return AzkarCategory(
      title: (json['title'] as String? ?? '').trim(),
      content: list,
    );
  }
}
