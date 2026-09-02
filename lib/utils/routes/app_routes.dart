import 'package:sadqah_jariyah_app/splash_screen.dart';
import 'package:sadqah_jariyah_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sadqah_jariyah_app/views/about_screen.dart';
import 'dart:developer';
import 'package:sadqah_jariyah_app/views/main_home_screen.dart';
import 'package:sadqah_jariyah_app/views/privacy_polices.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static CupertinoPageRoute cupertinoRoute(
    Widget screen, {
    RouteSettings? settings,
  }) {
    return CupertinoPageRoute(settings: settings, builder: (_) => screen);
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    // final args = settings.arguments;
    switch (settings.name) {
      case RoutesNames.initialRoute:
        return cupertinoRoute(const SplashScreen(), settings: settings);

      case RoutesNames.layout:
        return cupertinoRoute(const MainHomeScreen());

      case RoutesNames.privacyPolicy:
        return cupertinoRoute(const PrivacyPolicyPage());

      case RoutesNames.aboutUsScreen:
        log("-------------------------");
        return cupertinoRoute(AboutScreen());

      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return CupertinoPageRoute(builder: ((context) => const Scaffold()));
  }
}

Future<void> goTo(routesNames, {Object? args}) async {
  AppRoutes.navigatorKey.currentState!.pushNamed(routesNames, arguments: args);
}

Future<void> back() async => AppRoutes.navigatorKey.currentState!.pop();

Future<void> goAndFinish(routesNames, {Object? args}) async {
  AppRoutes.navigatorKey.currentState!.pushNamedAndRemoveUntil(
    routesNames,
    arguments: args,
    (route) => false,
  );
}

Future<void> popAndPush(routesNames, {Object? args}) async {
  AppRoutes.navigatorKey.currentState!.popAndPushNamed(
    routesNames,
    arguments: args,
  );
}
