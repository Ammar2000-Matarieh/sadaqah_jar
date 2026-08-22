import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/azkar_controller.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text(
          'الأذكار',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        actions: [
          Consumer<AzkarController>(
            builder: (context, value, child) => IconButton(
              tooltip: 'تصفير الكل',
              icon: const Icon(Icons.restart_alt, color: Colors.redAccent),
              onPressed: () => _confirmResetAll(context, value),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AzkarController>(
          builder: (context, value, child) => ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: value.azkarList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _ZikrButton(
                text: value.azkarList[index],
                count: value.counters[index],
                onTap: () => value.incrementCounter(index),
                onReset: () => value.resetCounter(index),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmResetAll(BuildContext context, AzkarController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تصفير كل التسبيحات؟'),
        content: const Text('رح يترجع كل العدادات لصفر.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.resetAll();
              Navigator.pop(ctx);
            },
            child: const Text(
              'تصفير',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZikrButton extends StatelessWidget {
  final String text;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const _ZikrButton({
    required this.text,
    required this.count,
    required this.onTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onReset, // ضغطة طويلة = تصفير سريع
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // زر التصفير الظاهر
            InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
