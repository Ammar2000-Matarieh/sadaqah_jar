import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/quran_controller.dart';
import 'package:sadqah_jariyah_app/controllers/surah_details_controller.dart';
import 'package:sadqah_jariyah_app/views/widgets/reciter_bottom_widget.dart';

class SurahDetailsPage extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  const SurahDetailsPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SurahDetailsController()..fetchSurahDetails(surahNumber),
      child: _SurahDetailsView(surahNumber: surahNumber, surahName: surahName),
    );
  }
}

class _SurahDetailsView extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  const _SurahDetailsView({required this.surahNumber, required this.surahName});

  @override
  State<_SurahDetailsView> createState() => _SurahDetailsViewState();
}

class _SurahDetailsViewState extends State<_SurahDetailsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  SurahDetailsController? _controller;
  int _lastScrolledIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.removeListener(_onControllerChanged);
    _controller = context.read<SurahDetailsController>();
    _controller!.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final c = _controller;
    if (c == null || !c.isPlaying) return;

    final index = c.currentAyahIndex;
    if (index == _lastScrolledIndex ||
        index < 0 ||
        index >= c.ayahToChunk.length) {
      return;
    }

    final prevChunk =
        (_lastScrolledIndex < 0 || _lastScrolledIndex >= c.ayahToChunk.length)
        ? -1
        : c.ayahToChunk[_lastScrolledIndex];
    _lastScrolledIndex = index;
    final chunk = c.ayahToChunk[index];

    if (chunk != prevChunk && _itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: chunk,
        alignment: 0.1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleToggleAudio() async {
    final controller = context.read<SurahDetailsController>();
    final reciterId = context.read<QuranController>().selectedReciter;
    final error = await controller.toggleAudio(
      surahNumber: widget.surahNumber,
      reciterId: reciterId,
    );
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _openReciterSheet() async {
    final c = context.read<SurahDetailsController>();
    if (c.isPlaying) await c.pause(); // بدل audioPlayer.pause()
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ReciterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SurahDetailsController, bool>(
      (c) => c.isLoading,
    );
    final chunkCount = context.select<SurahDetailsController, int>(
      (c) => c.chunks.length,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.surahName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: context.palette.topBar,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.record_voice_over, color: Colors.white),
              tooltip: 'تغيير القارئ',
              onPressed: _openReciterSheet,
            ),
            if (!isLoading) _PlayButton(onToggle: _handleToggleAudio),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                itemCount: chunkCount,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                itemBuilder: (_, i) => _AyahChunk(chunkIndex: i),
              ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onToggle;
  const _PlayButton({required this.onToggle});

  static const _gold = Color(0xFFF4A804);

  @override
  Widget build(BuildContext context) {
    final (isPlaying, isAudioLoading) = context
        .select<SurahDetailsController, (bool, bool)>(
          (c) => (c.isPlaying, c.isAudioLoading),
        );

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: isAudioLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
            )
          : IconButton(
              iconSize: 30,
              color: _gold,
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
              ),
              onPressed: onToggle,
            ),
    );
  }
}

class _AyahChunk extends StatelessWidget {
  final int chunkIndex;
  const _AyahChunk({required this.chunkIndex});

  @override
  Widget build(BuildContext context) {
    final c = context.read<SurahDetailsController>();
    // يُعاد بناء هذا المقطع فقط عند تغيّر قيمة الآية النشطة فيه
    final active = context.select<SurahDetailsController, int>(
      (c) => c.activeIn(chunkIndex),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).colorScheme.onSurface;
    final hlColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);
    final hlBg = hlColor.withValues(alpha: 0.12);

    return Text.rich(
      TextSpan(
        children: [
          for (final i in c.chunks[chunkIndex])
            TextSpan(
              text: "${c.ayahs[i]['text']} ﴿${c.ayahs[i]['numberInSurah']}﴾  ",
              style: TextStyle(
                fontSize: 20,
                height: 2.3,
                fontFamily: 'Cairo',
                fontWeight: i == active ? FontWeight.w700 : FontWeight.w500,
                color: i == active ? hlColor : baseColor,
                backgroundColor: i == active ? hlBg : null,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }
}
