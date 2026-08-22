import 'package:flutter/material.dart';

enum SplashStatus { loading, ready, error }

class SplashController extends ChangeNotifier {
  SplashController({this.splashDuration = const Duration(seconds: 5)});

  final Duration splashDuration;

  SplashStatus _status = SplashStatus.loading;
  SplashStatus get status => _status;

  Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();

    try {
      await _bootstrap();
      _status = SplashStatus.ready;
    } catch (_) {
      _status = SplashStatus.error;
    }

    // نضمن إن السبلاش ميختفيش قبل الوقت المحدد حتى لو الـ bootstrap خلص بسرعة
    final remaining = splashDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    notifyListeners();
  }

  Future<void> _bootstrap() async {
    // مثال حقيقي:
    // await AuthService.checkSession();
    // await RemoteConfigService.fetch();
  }
}
