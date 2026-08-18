import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sadqah_jariyah_app/main.dart';
import 'package:timezone/timezone.dart' as tz;

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

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _checkLocationAndCalculate();
    if (prayerTimes != null) {
      await scheduleAllPrayers(prayerTimes!);
    }
  }

  Future<void> _checkLocationAndCalculate() async {
    Coordinates coordinates;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      coordinates = Coordinates(31.9539, 35.9106); // فولباك عمّان
    } else {
      final position = await Geolocator.getCurrentPosition();
      coordinates = Coordinates(position.latitude, position.longitude);
    }

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    setState(() {
      prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(DateTime.now()),
        params,
      );
    });
  }

  Future<void> scheduleAllPrayers(PrayerTimes times) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.deleteNotificationChannel(
        channelId: 'prayer_channel_v2',
      );
    }

    final prayers = {
      'الفجر': times.fajr,
      'الظهر': times.dhuhr,
      'العصر': times.asr,
      'المغرب': times.maghrib,
      'العشاء': times.isha,
    };

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel_v3',
      'مواقيت الصلاة',
      channelDescription: 'تنبيهات وأذان أوقات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan12'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    int id = 100;
    for (final entry in prayers.entries) {
      final scheduled = tz.TZDateTime.from(entry.value, tz.local);
      debugPrint(
        '⏰ ${entry.key} -> raw:${entry.value} | scheduled:$scheduled | now:${tz.TZDateTime.now(tz.local)} | willSkip:${scheduled.isBefore(tz.TZDateTime.now(tz.local))}',
      );
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id++,
        title: 'حان الآن وقت صلاة ${entry.key}',
        body: 'الله أكبر الله أكبر',
        scheduledDate: scheduled,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    debugPrint('✅ تم جدولة صلوات اليوم بنجاح');
  }

  /// 🧪 اختبار فقط - تنبيه بعد دقيقتين
  Future<void> _scheduleTestNotification() async {
    try {
      final testTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(minutes: 2));

      const androidDetails = AndroidNotificationDetails(
        'prayer_channel_v3',
        'مواقيت الصلاة',
        channelDescription: 'تنبيهات وأذان أوقات الصلاة',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan12'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 999,
        title: '🧪 اختبار الأذان',
        body: 'إذا وصلك هذا التنبيه، الجدولة شغالة',
        scheduledDate: testTime,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('✅ TEST SCHEDULED: ${testTime.toString()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تمت الجدولة بنجاح — التنبيه بعد دقيقتين')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ TEST NOTIFICATION ERROR: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الجدولة: $e')));
      }
    }
  }

  Future<void> _debugPrintPending() async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    debugPrint('عدد التنبيهات المجدولة: ${pending.length}');
    for (final p in pending) {
      debugPrint('- id:${p.id} title:${p.title}');
    }
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _scheduleTestNotification,
                          child: const Text("اختبار: تنبيه بعد دقيقتين"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _debugPrintPending,
                          child: const Text("اطبع المجدول"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
    // final localTime = time.toLocal(); // 👈 هذا هو الحل
    final localTime = tz.TZDateTime.from(time, tz.local);
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
          DateFormat('hh:mm a').format(localTime), // 👈 استخدم localTime
          style: const TextStyle(
            fontSize: 18,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget _buildPrayerTile(String name, DateTime time) {
  //   return Card(
  //     elevation: 3,
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     child: ListTile(
  //       leading: const Icon(Icons.access_time, color: Colors.teal),
  //       title: Text(
  //         name,
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //       ),
  //       trailing: Text(
  //         DateFormat('hh:mm a').format(time),
  //         style: const TextStyle(
  //           fontSize: 18,
  //           color: Colors.teal,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
