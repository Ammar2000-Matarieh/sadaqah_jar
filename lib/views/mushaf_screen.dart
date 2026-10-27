// mushaf_screen.dart
// Dependencies (pubspec.yaml):
//   http: ^1.2.0
//   shared_preferences: ^2.2.0
//
// Usage in main.dart:
//   void main() => runApp(const MaterialApp(home: MushafScreen()));

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ───────────────────────── Config ─────────────────────────

const int kTotalPages = 604;

/// الوقت الأدنى لاعتبار الصفحة "مقروءة". للتجربة خليه 3 ثواني.
const Duration kMinDwell = Duration(seconds: 15);

/// كل كم صفحة مقروءة نحط علامة تلقائية.
const int kBookmarkEvery = 3;

const String kApi = 'https://api.quran.com/api/v4';

/// خطوط QCF v2 (خط لكل صفحة). تحقق من الرابط والترخيص قبل النشر.
String fontUrl(int page) =>
    'https://verses.quran.com/fonts/quran/hafs/v2/ttf/p$page.ttf';

String fontFamily(int page) => 'QCF2_P$page';

// ───────────────────────── Models ─────────────────────────

class MushafLine {
  final int number;
  final String text;
  MushafLine(this.number, this.text);
}

class MushafPageData {
  final int page;
  final List<MushafLine> lines;
  final String lastVerseKey; // مثال: 2:255
  MushafPageData(this.page, this.lines, this.lastVerseKey);
}

// ───────────────────────── Data layer ─────────────────────────

class QuranRepository {
  final Map<int, MushafPageData> _pages = {};
  final Set<int> _loadedFonts = {};

  Future<MushafPageData> getPage(int page) async {
    if (_pages.containsKey(page)) return _pages[page]!;

    final uri = Uri.parse(
      '$kApi/verses/by_page/$page'
      '?words=true&word_fields=code_v2,line_number,page_number&per_page=50',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load page $page (${res.statusCode})');
    }

    final verses = (jsonDecode(res.body)['verses'] as List);
    final Map<int, StringBuffer> lines = {};
    String lastKey = '';

    for (final v in verses) {
      lastKey = v['verse_key'] as String;
      for (final w in (v['words'] as List)) {
        final code = w['code_v2'] as String?;
        final line = w['line_number'] as int?;
        if (code == null || line == null) continue;
        lines.putIfAbsent(line, () => StringBuffer()).write(code);
      }
    }

    final sorted = lines.keys.toList()..sort();
    final data = MushafPageData(page, [
      for (final k in sorted) MushafLine(k, lines[k].toString()),
    ], lastKey);

    await _loadFont(page);
    _pages[page] = data;
    return data;
  }

  Future<void> _loadFont(int page) async {
    if (_loadedFonts.contains(page)) return;
    final res = await http.get(Uri.parse(fontUrl(page)));
    if (res.statusCode != 200) {
      throw Exception('Failed to load font for page $page');
    }
    final loader = FontLoader(fontFamily(page))
      ..addFont(Future.value(ByteData.view(res.bodyBytes.buffer)));
    await loader.load();
    _loadedFonts.add(page);
  }

  /// تحميل مسبق للصفحات المجاورة
  void prefetch(int page) {
    if (page < 1 || page > kTotalPages) return;
    getPage(page).catchError((_) => MushafPageData(page, [], ''));
  }
}

// ───────────────────────── Reading tracker ─────────────────────────

class ReadingTracker extends ChangeNotifier {
  static const _kBookmarkPage = 'bookmark_page';
  static const _kBookmarkVerse = 'bookmark_verse';
  static const _kReadPages = 'read_pages';
  static const _kLastPage = 'last_page';

  late SharedPreferences _prefs;

  int currentPage = 1;
  int? bookmarkPage;
  String? bookmarkVerse;
  final Set<int> readPages = {}; // كل المصحف (دائم)
  final Set<int> sessionRead = {}; // هذه الجلسة فقط

  Timer? _dwellTimer;
  String Function(int page)? lastVerseOf;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    bookmarkPage = _prefs.getInt(_kBookmarkPage);
    bookmarkVerse = _prefs.getString(_kBookmarkVerse);
    currentPage = _prefs.getInt(_kLastPage) ?? 1;
    readPages.addAll((_prefs.getStringList(_kReadPages) ?? []).map(int.parse));
    notifyListeners();
  }

  void onPageChanged(int page) {
    currentPage = page;
    _prefs.setInt(_kLastPage, page);
    _dwellTimer?.cancel();
    _dwellTimer = Timer(kMinDwell, () => _markRead(page));
    notifyListeners();
  }

  void _markRead(int page) {
    final isNew = sessionRead.add(page);
    readPages.add(page);
    _prefs.setStringList(
      _kReadPages,
      readPages.map((e) => e.toString()).toList(),
    );

    // كل 3 صفحات جديدة مقروءة بالجلسة → علامة تلقائية
    if (isNew && sessionRead.length % kBookmarkEvery == 0) {
      setBookmark(page);
    }
    notifyListeners();
  }

  void setBookmark(int page) {
    bookmarkPage = page;
    bookmarkVerse = lastVerseOf?.call(page);
    _prefs.setInt(_kBookmarkPage, page);
    if (bookmarkVerse != null) {
      _prefs.setString(_kBookmarkVerse, bookmarkVerse!);
    }
    notifyListeners();
  }

  void clearBookmark() {
    bookmarkPage = null;
    bookmarkVerse = null;
    _prefs.remove(_kBookmarkPage);
    _prefs.remove(_kBookmarkVerse);
    notifyListeners();
  }

  /// نستدعيها عند الخروج للخلفية
  void flush() {
    _prefs.setInt(_kLastPage, currentPage);
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }
}

// ───────────────────────── Screen ─────────────────────────

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen>
    with WidgetsBindingObserver {
  final _repo = QuranRepository();
  final _tracker = ReadingTracker();
  PageController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  Future<void> _boot() async {
    await _tracker.init();
    _tracker.lastVerseOf = (p) => _repo._pages[p]?.lastVerseKey ?? '';
    _controller = PageController(initialPage: _tracker.currentPage - 1);
    _tracker.onPageChanged(_tracker.currentPage);
    setState(() => _ready = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _tracker.flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tracker.flush();
    _tracker.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _jumpToBookmark() {
    final p = _tracker.bookmarkPage;
    if (p != null) _controller?.jumpToPage(p - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF6E9),
        appBar: AppBar(
          backgroundColor: context.palette.topBar,
          foregroundColor: Colors.white,
          title: AnimatedBuilder(
            animation: _tracker,
            builder: (_, _) => Text('صفحة ${_tracker.currentPage}'),
          ),
          actions: [
            AnimatedBuilder(
              animation: _tracker,
              builder: (_, _) {
                final isMarked = _tracker.bookmarkPage == _tracker.currentPage;
                return IconButton(
                  tooltip: 'علامة',
                  icon: Icon(isMarked ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () => isMarked
                      ? _tracker.clearBookmark()
                      : _tracker.setBookmark(_tracker.currentPage),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _ResumeBar(tracker: _tracker, onResume: _jumpToBookmark),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                reverse: true,
                itemCount: kTotalPages,
                onPageChanged: (i) {
                  final page = i + 1;
                  _tracker.onPageChanged(page);
                  _repo.prefetch(page + 1);
                  _repo.prefetch(page - 1);
                },
                itemBuilder: (_, i) =>
                    _MushafPage(page: i + 1, repo: _repo, tracker: _tracker),
              ),
            ),
            _ProgressFooter(tracker: _tracker),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _ResumeBar extends StatelessWidget {
  final ReadingTracker tracker;
  final VoidCallback onResume;
  const _ResumeBar({required this.tracker, required this.onResume});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tracker,
      builder: (_, _) {
        final p = tracker.bookmarkPage;
        if (p == null || p == tracker.currentPage) {
          return const SizedBox.shrink();
        }
        return Material(
          color: const Color(0xFFE8F3EE),
          child: InkWell(
            onTap: onResume,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: Color(0xFF1B5E4A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'متابعة القراءة من صفحة $p',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E4A),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_back_ios_new, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressFooter extends StatelessWidget {
  final ReadingTracker tracker;
  const _ProgressFooter({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tracker,
      builder: (_, _) => Container(
        color: context.palette.topBar,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قرأت بهذه الجلسة: ${tracker.sessionRead.length} صفحة',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                'الإجمالي: ${tracker.readPages.length}/$kTotalPages',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MushafPage extends StatelessWidget {
  final int page;
  final QuranRepository repo;
  final ReadingTracker tracker;
  const _MushafPage({
    required this.page,
    required this.repo,
    required this.tracker,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MushafPageData>(
      future: repo.getPage(page),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تعذر تحميل الصفحة'),
                TextButton(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final data = snap.data!;
        return AnimatedBuilder(
          animation: tracker,
          builder: (_, _) {
            final isBookmarked = tracker.bookmarkPage == page;
            final isRead = tracker.readPages.contains(page);
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: _PageBody(data: data),
                ),
                // شريط جانبي: أخضر = مقروءة
                if (isRead)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 4,
                      color: const Color(0xFF1B5E4A).withValues(alpha: .35),
                    ),
                  ),
                // ريبون العلامة
                if (isBookmarked)
                  Positioned(
                    top: 0,
                    left: 18,
                    child: Container(
                      width: 26,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC62828),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(6),
                        ),
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PageBody extends StatelessWidget {
  final MushafPageData data;
  const _PageBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final family = fontFamily(data.page);
    // الصفحتان 1 و2 فيهما أسطر أقل ومتمركزة
    final isShortPage = data.page <= 2;

    return LayoutBuilder(
      builder: (context, c) {
        final lineHeight =
            c.maxHeight / (isShortPage ? 15 : data.lines.length.clamp(1, 15));
        return Column(
          mainAxisAlignment: isShortPage
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            for (final line in data.lines)
              SizedBox(
                width: c.maxWidth,
                height: isShortPage ? lineHeight : null,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RepaintBoundary(
                    child: Text(
                      line.text,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 40,
                        color: const Color(0xFF1A1A1A),
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
