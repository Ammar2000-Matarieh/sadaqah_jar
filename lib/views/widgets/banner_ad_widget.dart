import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdIds {
  static String? get banner {
    if (kIsWeb) return null;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-1978820502904256/2613239282';
    }
    return null;
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static const _maxRetries = 3;

  BannerAd? _ad;
  AdSize? _size;
  bool _loaded = false;
  bool _gaveUp = false;
  int _retries = 0;
  int? _lastWidth;
  Timer? _retryTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (_lastWidth != width) {
      _lastWidth = width;
      _retries = 0;
      _loadAd(width);
    }
  }

  Future<void> _loadAd(int width) async {
    final unitId = AdIds.banner;
    if (unitId == null) return;

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;

    _retryTimer?.cancel();
    _ad?.dispose();

    final ad = BannerAd(
      adUnitId: unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          _retries = 0;
          setState(() {
            _loaded = true;
            _gaveUp = false;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          debugPrint('Banner failed: ${error.code} - ${error.message}');
          failedAd.dispose();
          if (identical(_ad, failedAd)) _ad = null;
          if (!mounted) return;
          setState(() => _loaded = false);
          _scheduleRetry(width);
        },
      ),
    );

    setState(() {
      _ad = ad;
      _size = size;
      _loaded = false;
    });
    await ad.load();
  }

  void _scheduleRetry(int width) {
    if (_retries >= _maxRetries) {
      setState(() => _gaveUp = true);
      return;
    }
    final delay = Duration(seconds: 10 * (1 << _retries)); // 10s, 20s, 40s
    _retries++;
    _retryTimer = Timer(delay, () {
      if (mounted) _loadAd(width);
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _size;
    if (AdIds.banner == null || size == null || _gaveUp) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final ad = _ad;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: 0.5),
          bottom: BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: size.height.toDouble(),
          child: _loaded && ad != null
              ? Center(
                  child: SizedBox(
                    width: size.width.toDouble(),
                    height: size.height.toDouble(),
                    child: AdWidget(ad: ad),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
