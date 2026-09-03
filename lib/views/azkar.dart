import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sadqah_jariyah_app/api/custom_api_services.dart';
import 'package:sadqah_jariyah_app/model/azkar.dart';
import 'package:sadqah_jariyah_app/model/azkar_categoriea.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/utils/enums/azkar_enum.dart';

class AzkarScreenNew extends StatefulWidget {
  const AzkarScreenNew({super.key});

  @override
  State<AzkarScreenNew> createState() => _AzkarScreenNewState();
}

class _AzkarScreenNewState extends State<AzkarScreenNew>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final Map<AzkarType, Future<AzkarCategory>> _futures = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load(AzkarType.morning);
    _load(AzkarType.evening);
  }

  void _load(AzkarType type) {
    _futures[type] = CustomApiServices.fetch(type);
  }

  Future<void> _refresh(AzkarType type) async {
    setState(() => _load(type));
    await _futures[type];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.wb_sunny_outlined,
                  color: AppColors.whiteColor,
                ),
                text: 'أذكار الصباح',
              ),
              Tab(
                icon: Icon(
                  Icons.nights_stay_outlined,
                  color: AppColors.whiteColor,
                ),
                text: 'أذكار المساء',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _AzkarTab(
              future: _futures[AzkarType.morning]!,
              onRetry: () => _refresh(AzkarType.morning),
            ),
            _AzkarTab(
              future: _futures[AzkarType.evening]!,
              onRetry: () => _refresh(AzkarType.evening),
            ),
          ],
        ),
      ),
    );
  }
}

class _AzkarTab extends StatelessWidget {
  final Future<AzkarCategory> future;
  final Future<void> Function() onRetry;

  const _AzkarTab({required this.future, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AzkarCategory>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString(),
            onRetry: onRetry,
          );
        }

        final category = snapshot.data!;
        return RefreshIndicator(
          onRefresh: onRetry,
          child: _AzkarList(category: category),
        );
      },
    );
  }
}

class _AzkarList extends StatefulWidget {
  final AzkarCategory category;
  const _AzkarList({required this.category});

  @override
  State<_AzkarList> createState() => _AzkarListState();
}

class _AzkarListState extends State<_AzkarList> {
  late List<int> _remaining;

  @override
  void initState() {
    super.initState();
    _resetCounts();
  }

  @override
  void didUpdateWidget(covariant _AzkarList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) _resetCounts();
  }

  void _resetCounts() {
    _remaining = widget.category.content.map((a) => a.repeat).toList();
  }

  void _decrement(int index) {
    if (_remaining[index] <= 0) return;
    HapticFeedback.lightImpact();
    setState(() => _remaining[index]--);
  }

  int get _doneCount => _remaining.where((r) => r == 0).length;

  @override
  Widget build(BuildContext context) {
    final total = widget.category.content.length;

    return Column(
      children: [
        _ProgressHeader(done: _doneCount, total: total),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: total,
            itemBuilder: (context, index) {
              final azkar = widget.category.content[index];
              return _AzkarCard(
                azkar: azkar,
                remaining: _remaining[index],
                onTap: () => _decrement(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressHeader({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$done من $total', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _AzkarCard extends StatelessWidget {
  final Azkar azkar;
  final int remaining;
  final VoidCallback onTap;

  const _AzkarCard({
    required this.azkar,
    required this.remaining,
    required this.onTap,
  });

  bool get _isDone => remaining == 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _isDone ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _isDone ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  azkar.text,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: FontWeight.w500,

                    color: AppColors.whiteColor,
                  ),
                ),
                if (azkar.source.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    azkar.source,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _isDone
                        ? Colors.green
                        : AppColors.primaryColor,
                    child: _isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '$remaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

// class AzkarService {
//   AzkarService._();

// }
