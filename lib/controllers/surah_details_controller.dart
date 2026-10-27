import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:sadqah_jariyah_app/api/custom_api_services.dart';

class SurahDetailsController extends ChangeNotifier {
  SurahDetailsController({CustomApiServices? apiServices})
    : _apiServices = apiServices ?? CustomApiServices() {
    _audioPlayer.onPlayerComplete.listen((_) => _onTrackComplete());
  }

  final CustomApiServices _apiServices;
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<dynamic> ayahs = [];
  bool isLoading = true;
  bool isPlaying = false;
  bool isAudioLoading = false;

  List<String> _currentPlaylist = [];
  int currentAyahIndex = 0;
  String? _lastPlayedReciter;

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> pause() async {
    await _audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }
  // ---------------- Chunks ----------------

  static const _chunkChars = 500; // عدّله بين 300 و 800 حسب الشاشة

  List<List<int>> chunks = []; // كل عنصر: فهارس الآيات في المقطع
  List<int> ayahToChunk = []; // فهرس الآية -> فهرس المقطع

  void _buildChunks() {
    chunks = [];
    ayahToChunk = List.filled(ayahs.length, 0);
    int chars = 0;

    for (var i = 0; i < ayahs.length; i++) {
      if (chunks.isEmpty || chars >= _chunkChars) {
        chunks.add([]);
        chars = 0;
      }
      chunks.last.add(i);
      ayahToChunk[i] = chunks.length - 1;
      chars += (ayahs[i]['text'] as String).length;
    }
  }

  /// فهرس الآية النشطة إذا كانت داخل هذا المقطع، وإلا -1
  int activeIn(int chunk) {
    if (!isPlaying ||
        currentAyahIndex < 0 ||
        currentAyahIndex >= ayahToChunk.length) {
      return -1;
    }
    return ayahToChunk[currentAyahIndex] == chunk ? currentAyahIndex : -1;
  }

  // ---------------- Surah Text ----------------
  Future<void> fetchSurahDetails(int surahNumber) async {
    isLoading = true;
    notifyListeners();
    try {
      ayahs = await _apiServices.fetchSurahDetails(surahNumber);
      _buildChunks(); // 👈 جديد
    } catch (e) {
      debugPrint('fetchSurahDetails error: $e');
      ayahs = [];
      chunks = [];
      ayahToChunk = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // Future<void> fetchSurahDetails(int surahNumber) async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     ayahs = await _apiServices.fetchSurahDetails(surahNumber);
  //   } catch (e) {
  //     debugPrint('fetchSurahDetails error: $e');
  //     ayahs = [];
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // ---------------- Audio ----------------

  /// يرجع رسالة خطأ إذا صار استثناء، عشان الـ View يعرضها بـ SnackBar
  Future<String?> toggleAudio({
    required int surahNumber,
    required String reciterId,
  }) async {
    final sameReciter = reciterId == _lastPlayedReciter;

    // 1) شغّال -> إيقاف مؤقت
    if (isPlaying && sameReciter) {
      await pause();
      return null;
    }

    // 2) متوقف مؤقتًا بنفس القارئ -> كمّل من نفس الآية
    if (!isPlaying &&
        sameReciter &&
        _currentPlaylist.isNotEmpty &&
        currentAyahIndex >= 0) {
      try {
        await _audioPlayer.resume();
        isPlaying = true;
        notifyListeners();
        return null;
      } catch (e) {
        debugPrint('resume failed: $e');
        // نكمل للأسفل ونعيد التشغيل من الآية الحالية
      }
    }

    // 3) تشغيل جديد (أول مرة، أو قارئ مختلف، أو انتهت السورة)
    isAudioLoading = true;
    notifyListeners();

    try {
      final audioUrls = await _apiServices.fetchSurahAudioUrls(
        surahNumber,
        reciterId,
      );
      if (audioUrls.isEmpty) throw Exception('لا يوجد صوت لهذا القارئ');

      // إذا بدّل القارئ أثناء السورة، يكمل من نفس الآية بدل البداية
      final startIndex =
          (currentAyahIndex >= 0 &&
              currentAyahIndex < audioUrls.length &&
              _currentPlaylist.isNotEmpty)
          ? currentAyahIndex
          : 0;

      _lastPlayedReciter = reciterId;
      await _playPlaylist(audioUrls, startIndex: startIndex);

      isPlaying = true;
      isAudioLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isPlaying = false;
      isAudioLoading = false;
      notifyListeners();
      return "فشل تشغيل الصوت لهذا القارئ";
    }
  }

  Future<void> _playPlaylist(List<String> urls, {int startIndex = 0}) async {
    _currentPlaylist = urls;
    currentAyahIndex = startIndex;
    notifyListeners();
    await _audioPlayer.play(UrlSource(urls[startIndex]));
  }

  Future<void> _onTrackComplete() async {
    if (currentAyahIndex + 1 < _currentPlaylist.length) {
      final nextIndex = currentAyahIndex + 1;
      try {
        await _audioPlayer.play(UrlSource(_currentPlaylist[nextIndex]));
        currentAyahIndex = nextIndex;
      } catch (e) {
        debugPrint('❌ فشل تشغيل الآية التالية: $e');
        isPlaying = false;
        currentAyahIndex = -1;
      }
    } else {
      isPlaying = false;
      currentAyahIndex = -1;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
