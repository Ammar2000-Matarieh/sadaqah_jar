import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text(
          'عن التطبيق',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                        color: const Color(0xFFDFB15B).withValues(alpha: 0.12),
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

              _buildFeatureRow(Icons.access_time_rounded, 'مواقيت الصلاة'),
              const SizedBox(height: 12),
              _buildFeatureRow(
                Icons.menu_book_rounded,
                'القرآن الكريم بالتفسير',
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(Icons.favorite_rounded, 'الأذكار والأدعية'),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFB15B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDFB15B).withValues(alpha: 0.2),
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
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'جميع الحقوق محفوظة © 2026',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
