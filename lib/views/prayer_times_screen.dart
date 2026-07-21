import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String title = "مواقيت الصلاة";
  PrayerTimes? prayerTimes;
  final player = AudioPlayer();
  bool isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _checkLocationAndCalculate();
    // التحقق كل دقيقة إذا حان وقت الصلاة
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkPrayerTime();
    });
  }

  Future<void> _checkLocationAndCalculate() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    final myCoordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    setState(() {
      prayerTimes = PrayerTimes(
        myCoordinates,
        DateComponents.from(DateTime.now()),
        params,
      );
    });
  }

  void _checkPrayerTime() {
    // منطق بسيط للمقارنة (يمكن تطويره لمقارنة الساعة والدقيقة بالضبط)
    // إذا كانت الساعة الحالية تساوي ساعة الصلاة، قم بتشغيل الأذان
  }

  Future<void> _toggleAdhan() async {
    if (isPlaying) {
      await player.stop();
    } else {
      await player.play(AssetSource('audio/azan12.mp3'));
    }
    setState(() => isPlaying = !isPlaying);
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: prayerTimes == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPrayerTile("الفجر", prayerTimes!.fajr),
                  _buildPrayerTile("الشروق", prayerTimes!.sunrise),
                  _buildPrayerTile("الظهر", prayerTimes!.dhuhr),
                  _buildPrayerTile("العصر", prayerTimes!.asr),
                  _buildPrayerTile("المغرب", prayerTimes!.maghrib),
                  _buildPrayerTile("العشاء", prayerTimes!.isha),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying ? Colors.red : Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _toggleAdhan,
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(isPlaying ? "إيقاف الأذان" : "تشغيل الأذان"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPrayerTile(String name, DateTime time) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.teal),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: Text(
          DateFormat('hh:mm a').format(time),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
