import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/list_of_providers.dart';
import 'package:sadqah_jariyah_app/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة التوقيت (مهم جداً للجدولة)
  tz.initializeTimeZones();

  // 2. تهيئة الإشعارات
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

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
            background: const Color(0xFFF6F8F7),
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

  @override
  void initState() {
    super.initState();
    fetchSurahDetails();
  }

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

  Future<void> toggleAudio() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
        setState(() => isPlaying = false);
        return;
      }
      final surah = widget.surahNumber.toString().padLeft(3, '0');
      final url = "https://server8.mp3quran.net/afs/$surah.mp3";
      await _audioPlayer.play(UrlSource(url));
      setState(() => isPlaying = true);
    } catch (e) {
      setState(() => isPlaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("فشل تشغيل الصوت")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFFFFDF9,
        ), // لون بيج خفيف مريح جداً لقراءة القرآن
        appBar: AppBar(
          title: Text(
            widget.surahName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor, //F4A804
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
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
                child: CircularProgressIndicator(color: Color(0xFF0F4C43)),
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
                        fontSize: 22,
                        height: 2.1,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
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
