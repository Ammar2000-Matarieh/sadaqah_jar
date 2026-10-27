import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

enum QiblaStatus { loading, ready, serviceOff, denied, deniedForever, noSensor }

class QiblaController extends ChangeNotifier {
  static const _kaabaLat = 21.422487;
  static const _kaabaLng = 39.826206;

  QiblaStatus status = QiblaStatus.loading;
  double? qiblaBearing; // زاوية القبلة من الشمال الحقيقي (0-360)
  double heading = 0; // اتجاه الجهاز بعد التنعيم

  StreamSubscription<CompassEvent>? _sub;
  bool _hasHeading = false;

  /// زاوية الدوران المطلوبة للسهم بالراديان
  double get arrowAngle => ((qiblaBearing ?? 0) - heading) * math.pi / 180;

  /// الفرق المطلق عن القبلة بالدرجات (0-180)
  double get offBy {
    final d = (((qiblaBearing ?? 0) - heading) % 360 + 360) % 360;
    return d > 180 ? 360 - d : d;
  }

  bool get isAligned => offBy < 3;

  Future<void> init() async {
    status = QiblaStatus.loading;
    notifyListeners();

    if (!await Geolocator.isLocationServiceEnabled()) {
      status = QiblaStatus.serviceOff;
      return notifyListeners();
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      status = QiblaStatus.denied;
      return notifyListeners();
    }
    if (perm == LocationPermission.deniedForever) {
      status = QiblaStatus.deniedForever;
      return notifyListeners();
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // كافي للقبلة، وأسرع وأوفر
          timeLimit: Duration(seconds: 15),
        ),
      );
      qiblaBearing = _bearingToKaaba(pos.latitude, pos.longitude);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) {
        status = QiblaStatus.serviceOff;
        return notifyListeners();
      }
      qiblaBearing = _bearingToKaaba(last.latitude, last.longitude);
    }

    final stream = FlutterCompass.events;
    if (stream == null) {
      status = QiblaStatus.noSensor;
      return notifyListeners();
    }

    await _sub?.cancel();
    _sub = stream.listen((e) {
      final h = e.heading;
      if (h == null) return;
      // تنعيم مع مراعاة الدوران الدائري (359° -> 1°)
      final delta = ((h - heading + 540) % 360) - 180;
      heading = _hasHeading ? (heading + delta * 0.2 + 360) % 360 : h;
      _hasHeading = true;
      status = QiblaStatus.ready;
      notifyListeners();
    });
  }

  static double _bearingToKaaba(double lat, double lng) {
    final phi1 = lat * math.pi / 180;
    final phi2 = _kaabaLat * math.pi / 180;
    final dLng = (_kaabaLng - lng) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(phi2);
    final x =
        math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
