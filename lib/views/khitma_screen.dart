import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/api/custom_api_services.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================
/// MODELS
/// ============================================================

enum JuzStatus { read, reading, unread }

class JuzEntry {
  final int number;
  final String? readerName;
  final JuzStatus status;

  const JuzEntry({
    required this.number,
    this.readerName,
    this.status = JuzStatus.unread,
  });

  JuzEntry copyWith({String? readerName, JuzStatus? status}) {
    return JuzEntry(
      number: number,
      readerName: readerName ?? this.readerName,
      status: status ?? this.status,
    );
  }
}

class Khatma {
  final String id;
  final String deceasedName; // "عن روح المرحوم/ة"
  final int khatmaNumber; // "الختمة رقم"
  final DateTime createdAt;
  final String? createdBy;
  final List<JuzEntry> juzList; // 30 entries

  const Khatma({
    required this.id,
    required this.deceasedName,
    required this.khatmaNumber,
    required this.createdAt,
    this.createdBy,
    required this.juzList,
  });

  int get readCount => juzList.where((j) => j.status == JuzStatus.read).length;
  int get readingCount =>
      juzList.where((j) => j.status == JuzStatus.reading).length;
  int get unreadCount =>
      juzList.where((j) => j.status == JuzStatus.unread).length;

  /// Reader name -> number of juz' claimed (read + reading), used by the
  /// stats ("تعداد") section.
  Map<String, int> get readerBreakdown {
    final map = <String, int>{};
    for (final j in juzList) {
      if (j.readerName == null || j.readerName!.trim().isEmpty) continue;
      map[j.readerName!] = (map[j.readerName!] ?? 0) + 1;
    }
    return map;
  }
}

/// ============================================================
/// REPOSITORY (swap this with a real API/Firestore/Supabase call)
/// ============================================================
///
/// Architecture note: keep this behind an interface so the screen
/// never talks to Dio/Firestore/etc. directly. In a real app this
/// would live in `data/repositories/khatma_repository_impl.dart`
/// implementing a `domain/repositories/khatma_repository.dart`
/// contract, injected via Riverpod/get_it.

abstract class KhatmaRepository {
  Future<Khatma> fetchKhatma(String id);
  Future<JuzEntry> claimJuz(String khatmaId, int juzNumber, String readerName);
}

class MockKhatmaRepository implements KhatmaRepository {
  @override
  Future<Khatma> fetchKhatma(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Khatma(
      id: id,
      deceasedName: 'عدنان رجب صابر دادر',
      khatmaNumber: 1,
      createdAt: DateTime(2026, 7, 20),
      createdBy: 'عنان دادر',
      juzList: List.generate(30, (i) {
        final n = i + 1;
        // seed a couple of sample states to mirror the screenshot
        if (n == 1) {
          return const JuzEntry(
            number: 1,
            readerName: 'عنان دادر',
            status: JuzStatus.read,
          );
        }
        if (n == 2) {
          return const JuzEntry(
            number: 2,
            readerName: 'عثمان رجب صابر دادر',
            status: JuzStatus.read,
          );
        }
        if (n == 3) {
          return const JuzEntry(number: 3, status: JuzStatus.reading);
        }
        if (n == 19) {
          return const JuzEntry(
            number: 19,
            readerName: 'ليان',
            status: JuzStatus.reading,
          );
        }
        if (n == 20) {
          return const JuzEntry(number: 20, status: JuzStatus.read);
        }
        if (n == 25) {
          return const JuzEntry(
            number: 25,
            readerName: 'عنان دادر',
            status: JuzStatus.read,
          );
        }
        if (n == 27) {
          return const JuzEntry(
            number: 27,
            readerName: 'يزن جمال',
            status: JuzStatus.reading,
          );
        }
        return JuzEntry(number: n);
      }),
    );
  }

  @override
  Future<JuzEntry> claimJuz(
    String khatmaId,
    int juzNumber,
    String readerName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return JuzEntry(
      number: juzNumber,
      readerName: readerName,
      status: JuzStatus.reading,
    );
  }
}

/// ============================================================
/// SCREEN
/// ============================================================

class KhatmaScreen extends StatefulWidget {
  final String khatmaId;
  final KhatmaRepository repository;

  const KhatmaScreen({
    super.key,
    required this.khatmaId,
    KhatmaRepository? repository,
  }) : repository = repository ?? const _NoRepo();

  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

// Fallback so the const constructor above doesn't break; swap for DI in real use.
class _NoRepo implements KhatmaRepository {
  const _NoRepo();
  @override
  Future<Khatma> fetchKhatma(String id) =>
      MockKhatmaRepository().fetchKhatma(id);
  @override
  Future<JuzEntry> claimJuz(
    String khatmaId,
    int juzNumber,
    String readerName,
  ) => MockKhatmaRepository().claimJuz(khatmaId, juzNumber, readerName);
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  Khatma? _khatma;
  bool _loading = true;
  String? _error;
  bool _showInfo = false;

  static const _green = Color(0xFF6FCF97);
  static const _orange = Color(0xFFE8916B);

  Future<void> _openExternal(String slug) async {
    final uri = Uri.parse(
      '${CustomApiServices.baseUrlAnan2}/$slug/${widget.khatmaId}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر فتح الرابط: $uri')));
    }
  }

  void _openDua() => _openExternal('doua');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.repository.fetchKhatma(widget.khatmaId);
      setState(() {
        _khatma = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل الختمة';
        _loading = false;
      });
    }
  }

  Future<void> _claimJuz(JuzEntry juz) async {
    if (juz.status != JuzStatus.unread) return; // already taken

    final name = await _promptForName();
    if (name == null || name.trim().isEmpty) return;

    final updated = await widget.repository.claimJuz(
      widget.khatmaId,
      juz.number,
      name.trim(),
    );

    setState(() {
      final list = [..._khatma!.juzList];
      final idx = list.indexWhere((j) => j.number == juz.number);
      list[idx] = updated;
      _khatma = Khatma(
        id: _khatma!.id,
        deceasedName: _khatma!.deceasedName,
        khatmaNumber: _khatma!.khatmaNumber,
        createdAt: _khatma!.createdAt,
        createdBy: _khatma!.createdBy,
        juzList: list,
      );
    });
  }

  Future<String?> _promptForName() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('باسم من تقرأ هذا الجزء؟'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'اكتب اسمك هنا'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  // void _openDua() {
  //   // TODO: navigate to the "دعاء ختم القرآن" screen/audio player.
  //   // e.g. Navigator.push(context, MaterialPageRoute(builder: (_) => KhatmaDuaScreen(khatmaId: widget.khatmaId)));
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _green,
        appBar: AppBar(
          title: Text(
            "'الختمات القرآنية",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF0F4C43),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F4C43), Color(0xFF18665B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final k = _khatma!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ختمة عن روح المرحوم/ة',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            k.deceasedName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الختمه رقم ${k.khatmaNumber}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildInfoToggle(k),
          const SizedBox(height: 16),
          _buildLegend(k),
          const SizedBox(height: 20),
          _buildJuzGrid(k),
          const SizedBox(height: 20),
          _buildDuaButton(),
          const SizedBox(height: 12),
          _buildActionRow(),
          const SizedBox(height: 28),
          _buildStatsSection(k),
        ],
      ),
    );
  }

  /// "معلومات الختمة" — toggleable pill that expands to show
  /// creation date / creator, matching the site's info button.
  Widget _buildInfoToggle(Khatma k) {
    return Column(
      children: [
        Center(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => setState(() => _showInfo = !_showInfo),
            child: const Text('معلومات الختمة'),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _showInfo
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow('تاريخ الإنشاء', _formatDate(k.createdAt)),
                  if (k.createdBy != null) _infoRow('أنشأها', k.createdBy!),
                  _infoRow('عدد الأجزاء', '${k.juzList.length}'),
                ],
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _buildLegend(Khatma k) {
    Widget chip(String label, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        chip('${k.unreadCount} غير مقروء', Colors.white, Colors.black87),
        chip('${k.readingCount} جاري القراءة', _orange, Colors.white),
        chip('${k.readCount} مقروء', Colors.white70, Colors.black87),
      ],
    );
  }

  Widget _buildJuzGrid(Khatma k) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: k.juzList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final juz = k.juzList[index];
        return _JuzCard(juz: juz, orange: _orange, onTap: () => _claimJuz(juz));
      },
    );
  }

  /// Separate orange "دعاء ختم القرآن" button, as on the site — visually
  /// distinct from the الفاتحة / يس / دعاء row below it.
  Widget _buildDuaButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openDua,
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.menu_book_rounded, size: 18),
        label: const Text('دعاء ختم القرآن'),
      ),
    );
  }

  Widget _buildActionRow() {
    Widget button(String label, VoidCallback onTap) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      ),
    );

    return Row(
      children: [
        button('الفاتحة', () => _openExternal('al-fatiha')),
        button('سورة يس', () => _openExternal('yaseen')),
        button('دعاء', () => _openExternal('doua')),
      ],
    );
  }

  /// "إحصائيات (تعداد)" section — per-reader breakdown of how many
  /// juz' each participant has claimed.
  Widget _buildStatsSection(Khatma k) {
    final breakdown = k.readerBreakdown;
    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'إحصائيات (تعداد)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'لا يوجد قراء بعد',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          else
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${e.value} جزء',
                        style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ============================================================
/// JUZ CARD WIDGET
/// ============================================================

class _JuzCard extends StatelessWidget {
  final JuzEntry juz;
  final Color orange;
  final VoidCallback onTap;

  const _JuzCard({
    required this.juz,
    required this.orange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTaken = juz.status != JuzStatus.unread;
    final bg = switch (juz.status) {
      JuzStatus.read => Colors.grey.shade300,
      JuzStatus.reading => orange,
      JuzStatus.unread => Colors.white,
    };
    final fg = juz.status == JuzStatus.reading ? Colors.white : Colors.black87;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isTaken ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${juz.number}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
                if (juz.readerName != null)
                  Text(
                    juz.readerName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: fg),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
