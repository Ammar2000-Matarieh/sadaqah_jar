import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
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
  final GlobalKey _textKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  List<int> _ayahStartOffsets = [];

  int _lastScrolledIndex = -1;

  // 👇 خزّن الـ reference هون
  SurahDetailsController? _controller;

  static const Color highlightColor = Color(0xFF1565C0);
  static const Color highlightBg = Color(0x1A1565C0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // احتراس من الاستماع المكرر إذا didChangeDependencies نادى أكتر من مرة
    if (_controller != null) {
      _controller!.removeListener(_onControllerChanged);
    }
    _controller = context.read<SurahDetailsController>();
    _controller!.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.currentAyahIndex != _lastScrolledIndex &&
        controller.isPlaying) {
      _lastScrolledIndex = controller.currentAyahIndex;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentAyah(controller.currentAyahIndex),
      );
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // نستمع لتغيّر currentAyahIndex عشان نعمل scroll تلقائي
  //   final controller = context.read<SurahDetailsController>();
  //   controller.addListener(_onControllerChanged);
  // }

  // void _onControllerChanged() {
  //   final controller = context.read<SurahDetailsController>();
  //   if (controller.currentAyahIndex != _lastScrolledIndex &&
  //       controller.isPlaying) {
  //     _lastScrolledIndex = controller.currentAyahIndex;
  //     WidgetsBinding.instance.addPostFrameCallback(
  //       (_) => _scrollToCurrentAyah(controller.currentAyahIndex),
  //     );
  //   }
  // }

  // @override
  // void dispose() {
  //   context.read<SurahDetailsController>().removeListener(_onControllerChanged);
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  void dispose() {
    // ✅ ما في context.read هون — استخدم الـ reference المخزّن
    _controller?.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentAyah(int index) {
    if (index < 0 || index >= _ayahStartOffsets.length) return;

    final renderObject = _textKey.currentContext?.findRenderObject();
    if (renderObject is! RenderParagraph) return;

    final start = _ayahStartOffsets[index];
    final end = index + 1 < _ayahStartOffsets.length
        ? _ayahStartOffsets[index + 1]
        : renderObject.text.toPlainText().length;

    final boxes = renderObject.getBoxesForSelection(
      TextSelection(baseOffset: start, extentOffset: end),
    );
    if (boxes.isEmpty) return;

    final scrollableBox =
        _scrollController.position.context.storageContext.findRenderObject()
            as RenderBox;

    final localPoint = renderObject.localToGlobal(
      boxes.first.toRect().topLeft,
      ancestor: scrollableBox,
    );

    final targetOffset = (_scrollController.offset + localPoint.dy - 140).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleToggleAudio(SurahDetailsController controller) async {
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SurahDetailsController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF9),
        appBar: AppBar(
          title: Text(
            widget.surahName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Consumer<QuranController>(
              builder: (context, quranController, _) {
                return IconButton(
                  icon: const Icon(
                    Icons.record_voice_over,
                    color: Colors.white,
                  ),
                  tooltip: 'تغيير القارئ',
                  onPressed: () async {
                    if (controller.isPlaying) {
                      await controller.audioPlayer.pause();
                    }
                    if (context.mounted) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => const ReciterBottomSheet(),
                      );
                    }
                  },
                );
              },
            ),
            if (!controller.isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: controller.isAudioLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF4A804),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          controller.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: const Color(0xFFF4A804),
                          size: 30,
                        ),
                        onPressed: () => _handleToggleAudio(controller),
                      ),
              ),
          ],
        ),
        body: controller.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: _buildFlowingAyahs(controller),
              ),
      ),
    );
  }

  Widget _buildFlowingAyahs(SurahDetailsController controller) {
    final spans = <InlineSpan>[];
    _ayahStartOffsets = [];
    int runningLength = 0;

    for (int i = 0; i < controller.ayahs.length; i++) {
      final ayah = controller.ayahs[i];
      final isActive = i == controller.currentAyahIndex && controller.isPlaying;
      final text = "${ayah['text']} ﴿${ayah['numberInSurah']}﴾  ";

      _ayahStartOffsets.add(runningLength);
      runningLength += text.length;

      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 20,
            height: 2.3,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Cairo',
            color: isActive ? highlightColor : Colors.black,
            backgroundColor: isActive ? highlightBg : Colors.transparent,
          ),
        ),
      );
    }

    return RichText(
      key: _textKey,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }
}

// Future<void> fetchSurahDetails() async {
//     final url = Uri.parse(
//       'https://api.alquran.cloud/v1/surah/${widget.surahNumber}',
//     );
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           ayahs = data['data']['ayahs'];
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> toggleAudio() async {
//     try {
//       final reciterId = Provider.of<QuranController>(
//         context,
//         listen: false,
//       ).selectedReciter;

//       if (isPlaying && reciterId == _lastPlayedReciter) {
//         await _audioPlayer.pause();
//         setState(() => isPlaying = false);
//         return;
//       }

//       setState(() => isAudioLoading = true);

//       final url = Uri.parse(
//         'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/$reciterId',
//       );
//       final response = await http.get(url);

//       if (response.statusCode != 200) {
//         throw Exception('القارئ غير مدعوم لهذه السورة');
//       }

//       final data = json.decode(response.body);
//       final List audioAyahs = data['data']['ayahs'];
//       final audioUrls = audioAyahs
//           .map((a) => a['audio'] as String?)
//           .where((u) => u != null && u.isNotEmpty)
//           .cast<String>()
//           .toList();

//       if (audioUrls.isEmpty) throw Exception('لا يوجد صوت لهذا القارئ');

//       _lastPlayedReciter = reciterId;
//       await _playPlaylist(audioUrls);

//       setState(() {
//         isPlaying = true;
//         isAudioLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isPlaying = false;
//         isAudioLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("فشل تشغيل الصوت لهذا القارئ")),
//         );
//       }
//     }
//   }

//   Future<void> _playPlaylist(List<String> urls) async {
//     _currentPlaylist = urls;
//     setState(() => _currentAyahIndex = 0);
//     await _audioPlayer.play(UrlSource(urls.first));
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentAyah());
//   }

//   void _scrollToCurrentAyah() {
//     if (_currentAyahIndex < 0 ||
//         _currentAyahIndex >= _ayahStartOffsets.length) {
//       return;
//     }
//     final renderObject = _textKey.currentContext?.findRenderObject();
//     if (renderObject is! RenderParagraph) return;

//     final start = _ayahStartOffsets[_currentAyahIndex];
//     final end = _currentAyahIndex + 1 < _ayahStartOffsets.length
//         ? _ayahStartOffsets[_currentAyahIndex + 1]
//         : renderObject.text.toPlainText().length;

//     final boxes = renderObject.getBoxesForSelection(
//       TextSelection(baseOffset: start, extentOffset: end),
//     );
//     if (boxes.isEmpty) return;

//     final scrollableBox =
//         _scrollController.position.context.storageContext.findRenderObject()
//             as RenderBox;

//     final localPoint = renderObject.localToGlobal(
//       boxes.first.toRect().topLeft,
//       ancestor: scrollableBox,
//     );

//     final targetOffset = (_scrollController.offset + localPoint.dy - 140).clamp(
//       0.0,
//       _scrollController.position.maxScrollExtent,
//     );

//     _scrollController.animateTo(
//       targetOffset,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeOut,
//     );
//   }
