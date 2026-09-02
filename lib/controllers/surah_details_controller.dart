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

  // ---------------- Surah Text ----------------

  Future<void> fetchSurahDetails(int surahNumber) async {
    isLoading = true;
    notifyListeners();
    try {
      ayahs = await _apiServices.fetchSurahDetails(surahNumber);
    } catch (e) {
      debugPrint('fetchSurahDetails error: $e');
      ayahs = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- Audio ----------------

  /// يرجع رسالة خطأ إذا صار استثناء، عشان الـ View يعرضها بـ SnackBar
  Future<String?> toggleAudio({
    required int surahNumber,
    required String reciterId,
  }) async {
    if (isPlaying && reciterId == _lastPlayedReciter) {
      await _audioPlayer.pause();
      isPlaying = false;
      notifyListeners();
      return null;
    }

    isAudioLoading = true;
    notifyListeners();

    try {
      final audioUrls = await _apiServices.fetchSurahAudioUrls(
        surahNumber,
        reciterId,
      );

      if (audioUrls.isEmpty) {
        throw Exception('لا يوجد صوت لهذا القارئ');
      }

      _lastPlayedReciter = reciterId;
      await _playPlaylist(audioUrls);

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

  Future<void> _playPlaylist(List<String> urls) async {
    _currentPlaylist = urls;
    currentAyahIndex = 0;
    notifyListeners(); // عشان الـ View يعمل scroll لأول آية
    await _audioPlayer.play(UrlSource(urls.first));
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
