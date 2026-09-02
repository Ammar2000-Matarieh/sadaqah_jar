import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';

class RateAppBottomSheet extends StatefulWidget {
  const RateAppBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RateAppBottomSheet(),
    );
  }

  @override
  State<RateAppBottomSheet> createState() => _RateAppBottomSheetState();
}

class _RateAppBottomSheetState extends State<RateAppBottomSheet> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: Icon(
              Icons.favorite_rounded,
              size: 32,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'كيف تقيّم تجربتك معنا؟',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'رأيك يساعدنا نطور التطبيق أكثر',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starIndex),
                icon: Icon(
                  starIndex <= _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 36,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating == 0 ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'إرسال',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    Navigator.pop(context);

    if (_rating >= 4) {
      // تقييم عالي → المتجر مباشرة
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        inAppReview.openStoreListing(
          appStoreId: 'YOUR_APP_STORE_ID', // لـ iOS
        );
      }
    } else {
      // تقييم منخفض → feedback داخلي بدل المتجر
      _showFeedbackDialog();
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('شاركنا رأيك'),
        content: const Text('ما الذي يمكننا تحسينه بالتطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: افتح شاشة فيدباك أو ايميل دعم
            },
            child: const Text('إرسال ملاحظات'),
          ),
        ],
      ),
    );
  }
}
