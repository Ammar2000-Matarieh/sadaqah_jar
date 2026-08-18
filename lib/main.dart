import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/list_of_providers.dart';
import 'package:sadqah_jariyah_app/controllers/quran_controller.dart';
import 'package:sadqah_jariyah_app/splash_screen.dart';
import 'package:sadqah_jariyah_app/views/quran_screen.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة التوقيت + تحديد منطقة عمّان الزمنية
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Amman'));

  // 2. إعدادات التهيئة لكل منصة%
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  const AndroidNotificationChannel prayerChannel = AndroidNotificationChannel(
    'prayer_channel_v3',
    'مواقيت الصلاة',
    description: 'تنبيهات وأذان أوقات الصلاة',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('azan12'),
    playSound: true,
    audioAttributesUsage: AudioAttributesUsage.alarm, // 👈 ضيفها هون
  );

  // 3. إنشاء notification channel صريح - لازم يكون النوع محدد صراحة
  // const AndroidNotificationChannel prayerChannel = AndroidNotificationChannel(
  //   'prayer_channel_v3',
  //   'مواقيت الصلاة',
  //   description: 'تنبيهات وأذان أوقات الصلاة',
  //   importance: Importance.max,
  //   sound: RawResourceAndroidNotificationSound('azan12'),
  //   playSound: true,
  // );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  await androidPlugin?.createNotificationChannel(prayerChannel);
  await androidPlugin?.requestNotificationsPermission();
  await androidPlugin?.requestExactAlarmsPermission();

  final IOSFlutterLocalNotificationsPlugin? iosPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

  await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(const ReligiousApp());
}

class ReligiousApp extends StatelessWidget {
  const ReligiousApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: listOfProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'صدقة جارية',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            primary: AppColors.primaryColor,
            secondary: const Color(0xFFDFB15B),
          ),
          fontFamily: 'Cairo',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SurahDetailsPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  const SurahDetailsPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });
  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  List ayahs = [];
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSurahDetails();

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_currentAyahIndex < _currentPlaylist.length - 1) {
        _currentAyahIndex++;
        _audioPlayer.play(UrlSource(_currentPlaylist[_currentAyahIndex]));
      } else {
        if (mounted) setState(() => isPlaying = false);
      }
    });
  }

  //   // أوقف الصوت تلقائيًا لو المستخدم غيّر القارئ وهو بنفس الصفحة
  //   _audioPlayer.onPlayerComplete.listen((_) {
  //     if (mounted) setState(() => isPlaying = false);
  //   });
  // }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchSurahDetails() async {
    final url = Uri.parse(
      'https://api.alquran.cloud/v1/surah/${widget.surahNumber}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ayahs = data['data']['ayahs'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<String> _currentPlaylist = [];
  int _currentAyahIndex = 0;
  String? _lastPlayedReciter; // نتتبع آخر قارئ شغّلنا فيه

  Future<void> toggleAudio() async {
    try {
      final reciterId = Provider.of<QuranController>(
        context,
        listen: false,
      ).selectedReciter;

      // لو نفس القارئ وعم يشتغل، بس pause/resume
      if (isPlaying && reciterId == _lastPlayedReciter) {
        await _audioPlayer.pause();
        setState(() => isPlaying = false);
        return;
      }

      setState(() => isAudioLoading = true);

      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/$reciterId',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('القارئ غير مدعوم لهذه السورة');
      }

      final data = json.decode(response.body);
      final List audioAyahs = data['data']['ayahs'];
      final audioUrls = audioAyahs
          .map((a) => a['audio'] as String?)
          .where((u) => u != null && u.isNotEmpty)
          .cast<String>()
          .toList();

      if (audioUrls.isEmpty) throw Exception('لا يوجد صوت لهذا القارئ');

      _lastPlayedReciter = reciterId;
      await _playPlaylist(audioUrls);

      setState(() {
        isPlaying = true;
        isAudioLoading = false;
      });
    } catch (e) {
      setState(() {
        isPlaying = false;
        isAudioLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل تشغيل الصوت لهذا القارئ")),
        );
      }
    }
  }

  Future<void> _playPlaylist(List<String> urls) async {
    _currentPlaylist = urls;
    _currentAyahIndex = 0;
    await _audioPlayer.play(UrlSource(urls.first));
  }

  // Future<void> toggleAudio() async {
  //   try {
  //     if (isPlaying) {
  //       await _audioPlayer.pause();
  //       setState(() => isPlaying = false);
  //       return;
  //     }

  //     setState(() => isAudioLoading = true);

  //     // القارئ الحالي من الكنترولر بدل ما يكون ثابت
  //     final reciterId = Provider.of<QuranController>(
  //       context,
  //       listen: false,
  //     ).selectedReciter;

  //     final surah = widget.surahNumber.toString().padLeft(3, '0');
  //     final url =
  //         "https://cdn.islamic.network/quran/audio-surah/128/$reciterId/$surah.mp3";

  //     await _audioPlayer.play(UrlSource(url));
  //     setState(() {
  //       isPlaying = true;
  //       isAudioLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isPlaying = false;
  //       isAudioLoading = false;
  //     });
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text("فشل تشغيل الصوت")));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF9),
        appBar: AppBar(
          title: Text(
            widget.surahName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Consumer<QuranController>(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(
                    Icons.record_voice_over,
                    color: Colors.white,
                  ),
                  tooltip: 'تغيير القارئ',
                  onPressed: () async {
                    // أوقف الصوت الحالي قبل ما تفتح الاختيار
                    if (isPlaying) {
                      await _audioPlayer.pause();
                      setState(() => isPlaying = false);
                    }
                    if (context.mounted) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => const ReciterBottomSheet(),
                      );
                    }
                  },
                );
              },
            ),
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: isAudioLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF4A804),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: const Color(0xFFF4A804),
                          size: 30,
                        ),
                        onPressed: toggleAudio,
                      ),
              ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                itemCount: ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = ayahs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "${ayah['text']} ﴿${ayah['numberInSurah']}﴾",
                      style: const TextStyle(
                        fontSize: 18,
                        height: 2.1,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
