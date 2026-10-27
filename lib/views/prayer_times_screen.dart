import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/main.dart';
import 'package:sadqah_jariyah_app/utils/extensions/size.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String title = "مواقيت الصلاة";
  PrayerTimes? prayerTimes;
  bool isPlaying = false;
  String? _currentPrayerName;

  Timer? _watcher;
  final Set<String> _firedToday = {};
  DateTime _lastScheduledDay = DateTime(2000);

  final Map<String, int> _notificationIds = {};

  int? _currentFiredId;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _checkLocationAndCalculate();
    if (prayerTimes != null) {
      await scheduleAllPrayers();

      _startForegroundWatcher();
    }
    return;
  }

  static const bool _useRealGps = true; // all places

  Coordinates? _lastCoordinates;

  Future<void> _checkLocationAndCalculate() async {
    Coordinates coordinates;

    if (!_useRealGps) {
      coordinates = Coordinates(31.9539, 35.9106);
      debugPrint('📍 [DEV MODE] إحداثيات مفروضة: عمّان');
    } else {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        coordinates = Coordinates(31.9539, 35.9106);
        debugPrint('📍 Fallback used (location service disabled): Amman');
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          coordinates = Coordinates(31.9539, 35.9106); // فولباك عمّان
          debugPrint('📍 Fallback used (no permission): Amman');
        } else {
          final position = await Geolocator.getCurrentPosition();
          coordinates = Coordinates(position.latitude, position.longitude);
          debugPrint(
            '📍 Lat: ${position.latitude}, Lng: ${position.longitude}',
          );
        }
      }
    }

    _lastCoordinates = coordinates;

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    setState(() {
      prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(DateTime.now()),
        params,
      );
    });
    return;
  }

  tz.TZDateTime _asAmmanLocal(DateTime raw) {
    return tz.TZDateTime.from(raw, tz.local);
  }

  Map<String, DateTime> _prayerMapFor(DateTime date) {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final times = PrayerTimes(
      _lastCoordinates ?? Coordinates(31.9539, 35.9106),
      DateComponents.from(date),
      params,
    );
    return {
      'الفجر': times.fajr,
      'الظهر': times.dhuhr,
      'العصر': times.asr,
      'المغرب': times.maghrib,
      'العشاء': times.isha,
    };
  }

  String _keyFor(String prayerName, tz.TZDateTime local) =>
      '$prayerName-${local.year}-${local.month}-${local.day}';

  Future<void> scheduleAllPrayers() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    _notificationIds.clear();

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

    const darwinDetails = DarwinNotificationDetails(
      sound: 'azan12.caf',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    int id = 100;
    final now = tz.TZDateTime.now(tz.local);

    for (int dayOffset = 0; dayOffset < 10; dayOffset++) {
      final date = DateTime.now().add(Duration(days: dayOffset));
      final prayers = _prayerMapFor(date);

      for (final entry in prayers.entries) {
        final scheduled = _asAmmanLocal(entry.value);
        if (scheduled.isBefore(now)) continue;

        final key = _keyFor(entry.key, scheduled);
        final thisId = id++;
        _notificationIds[key] = thisId;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: thisId,
          title: 'حان الآن وقت صلاة ${entry.key}',
          body: 'الله أكبر الله أكبر',
          scheduledDate: scheduled,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    _lastScheduledDay = DateTime.now();
    debugPrint('✅ تم جدولة صلوات ${_notificationIds.length} إشعار بنجاح');
    return;
  }

  void _startForegroundWatcher() {
    _watcher?.cancel();
    _watcher = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _checkAndPlay(),
    );
  }

  void _checkAndPlay() {
    if (prayerTimes == null) return;
    final now = DateTime.now();

    if (now.day != _lastScheduledDay.day ||
        now.month != _lastScheduledDay.month) {
      _checkLocationAndCalculate().then((_) => scheduleAllPrayers());
      _firedToday.clear();
    }

    final prayers = _prayerMap(prayerTimes!);

    for (final entry in prayers.entries) {
      final local = _asAmmanLocal(entry.value);
      final key = _keyFor(entry.key, local);
      final matches = now.hour == local.hour && now.minute == local.minute;
      if (matches && !_firedToday.contains(key)) {
        _firedToday.add(key);
        setState(() {
          isPlaying = true;
          _currentPrayerName = entry.key;
          _currentFiredId = _notificationIds[key];
        });
      }
    }
  }

  Map<String, DateTime> _prayerMap(PrayerTimes times) => {
    'الفجر': times.fajr,
    'الظهر': times.dhuhr,
    'العصر': times.asr,
    'المغرب': times.maghrib,
    'العشاء': times.isha,
  };

  Future<void> _stopAdhan() async {
    if (_currentFiredId != null) {
      await flutterLocalNotificationsPlugin.cancel(id: _currentFiredId!);
    }
    setState(() {
      isPlaying = false;
      _currentPrayerName = null;
      _currentFiredId = null;
    });
    return;
  }

  @override
  void dispose() {
    _watcher?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: prayerTimes == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildPrayerTile("الفجر", prayerTimes!.fajr),
                    _buildPrayerTile("الشروق", prayerTimes!.sunrise),
                    _buildPrayerTile("الظهر", prayerTimes!.dhuhr),
                    _buildPrayerTile("العصر", prayerTimes!.asr),
                    _buildPrayerTile("المغرب", prayerTimes!.maghrib),
                    _buildPrayerTile("العشاء", prayerTimes!.isha),
                    // const Spacer(),
                    SizedBox(height: 29.h),
                    if (isPlaying)
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_up,
                              color: Colors.teal,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'حان الآن وقت صلاة ${_currentPrayerName ?? ""}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _stopAdhan,
                              icon: const Icon(Icons.stop_circle, size: 20),
                              label: const Text('إيقاف'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleRefresh() async {
    await _checkLocationAndCalculate();
    if (prayerTimes != null) {
      await scheduleAllPrayers();
      _firedToday.clear(); // تصفير حتى ما تتكرر إشعارات نفس اليوم بشكل خاطئ
    }
  }

  Widget _buildPrayerTile(String name, DateTime time) {
    final localTime = _asAmmanLocal(time);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: AppColors.primaryColor),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: Text(
          DateFormat('hh:mm a').format(localTime),
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
