import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_item_widget.dart';

class CustomAboutUsWidget extends StatelessWidget {
  const CustomAboutUsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mosque_rounded,
                      size: 60,
                      color: Color(0xFFB48425),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تطبيق متقن',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    ' تطبيق يساعدك على أداء العبادات اليومية والمحافظة على الأذكار والقرآن الكريم.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CustomItemWidget(
              icon: Icons.access_time_rounded,

              label: 'مواقيت الصلاة',
            ),
            const SizedBox(height: 12),
            CustomItemWidget(
              icon: Icons.menu_book_rounded,
              label: 'القرآن الكريم بالتفسير',
            ),
            const SizedBox(height: 12),
            CustomItemWidget(
              icon: Icons.favorite_rounded,

              label: 'الأذكار والأدعية',
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.secColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secColor.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾', // TODO: استبدل بآية مناسبة لتطبيقك
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB48425),
                  height: 1.9,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              height: 1,
              color: AppColors.primaryColor.withValues(alpha: 0.08),
            ),

            const SizedBox(height: 20),

            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.greyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'جميع الحقوق محفوظة © 2026',
              style: TextStyle(fontSize: 12, color: AppColors.greyColor),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
