import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/qeblah_controller.dart';

class AlqeblahScreen extends StatelessWidget {
  const AlqeblahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QiblaController()..init(),
      child: Scaffold(body: const _QiblaBody()),
    );
  }
}

class _QiblaBody extends StatefulWidget {
  const _QiblaBody();

  @override
  State<_QiblaBody> createState() => _QiblaBodyState();
}

class _QiblaBodyState extends State<_QiblaBody> {
  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<QiblaController>();

    switch (c.status) {
      case QiblaStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case QiblaStatus.serviceOff:
        return _Message(
          'خدمة الموقع (GPS) مغلقة',
          action: 'فتح الإعدادات',
          onAction: Geolocator.openLocationSettings,
        );
      case QiblaStatus.denied:
        return _Message(
          'نحتاج إذن الموقع لتحديد القبلة',
          action: 'إعادة المحاولة',
          onAction: context.read<QiblaController>().init,
        );
      case QiblaStatus.deniedForever:
        return _Message(
          'تم رفض إذن الموقع نهائياً، فعّله من إعدادات التطبيق',
          action: 'فتح إعدادات التطبيق',
          onAction: Geolocator.openAppSettings,
        );
      case QiblaStatus.noSensor:
        return const _Message('جهازك لا يحتوي على حساس البوصلة');
      case QiblaStatus.ready:
        break;
    }

    if (c.isAligned && !_wasAligned) HapticFeedback.mediumImpact();
    _wasAligned = c.isAligned;

    final scheme = Theme.of(context).colorScheme;
    final color = c.isAligned ? Colors.green : scheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            c.isAligned
                ? 'أنت باتجاه القبلة ✓'
                : 'دوّر الجهاز حتى يتجه السهم للأعلى',
            style: TextStyle(fontSize: 16, color: color),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: c.arrowAngle,
                  child: Icon(
                    Icons.navigation_rounded,
                    size: 150,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${c.qiblaBearing!.toStringAsFixed(0)}° من الشمال',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}
