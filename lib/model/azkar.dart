class Azkar {
  final String text;
  final int repeat;
  final String source;

  const Azkar({required this.text, required this.repeat, this.source = ''});

  factory Azkar.fromJson(Map<String, dynamic> json) {
    final rawRepeat = json['repeat'];
    final repeat = rawRepeat is int
        ? rawRepeat
        : int.tryParse('$rawRepeat') ?? 1;

    return Azkar(
      text: (json['zekr'] as String? ?? '').trim(),
      repeat: repeat <= 0 ? 1 : repeat,
      source: (json['bless'] as String? ?? '').trim(),
    );
  }
}
