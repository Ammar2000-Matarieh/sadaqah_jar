import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sadqah_jariyah_app/run_app.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Amman'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  await androidPlugin?.createNotificationChannel(prayerChannel);

  final bool? notificationsGranted = await androidPlugin
      ?.requestNotificationsPermission();
  debugPrint('🔔 Notifications permission granted: $notificationsGranted');

  final bool? exactAlarmGranted = await androidPlugin
      ?.requestExactAlarmsPermission();
  debugPrint('⏰ Exact alarm permission granted: $exactAlarmGranted');

  final IOSFlutterLocalNotificationsPlugin? iosPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
  await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(const ReligiousApp());
}

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sadqah_jariyah_app/run_app.dart';
// import 'package:timezone/data/latest.dart' as tzdata;
// import 'package:timezone/timezone.dart' as tz;

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   tzdata.initializeTimeZones();
//   tz.setLocalLocation(tz.getLocation('Asia/Amman'));

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   const DarwinInitializationSettings initializationSettingsIOS =
//       DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );

//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsIOS,
//   );

//   await flutterLocalNotificationsPlugin.initialize(
//     settings: initializationSettings,
//   );

//   const AndroidNotificationChannel prayerChannel = AndroidNotificationChannel(
//     'prayer_channel_v3',
//     'مواقيت الصلاة',
//     description: 'تنبيهات وأذان أوقات الصلاة',
//     importance: Importance.max,
//     sound: RawResourceAndroidNotificationSound('azan12'),
//     playSound: true,
//     audioAttributesUsage: AudioAttributesUsage.alarm,
//   );

//   final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
//       flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >();

//   await androidPlugin?.createNotificationChannel(prayerChannel);
//   await androidPlugin?.requestNotificationsPermission();
//   await androidPlugin?.requestExactAlarmsPermission();

//   final IOSFlutterLocalNotificationsPlugin? iosPlugin =
//       flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin
//           >();
//   await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

//   runApp(const ReligiousApp());
// }
