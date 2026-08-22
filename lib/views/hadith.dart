import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/hadith_controller.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HadithController>(context, listen: false).getHadiths();
    });

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Consumer<HadithController>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (value.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 42,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تعذر تحميل الأحاديث',
                    style: TextStyle(color: Color(0xFF334155), fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => value.getHadiths(),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: value.getHadiths,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: value.hadiths.length,
              itemBuilder: (context, index) {
                final hadith = value.hadiths[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hadith['text']!,
                          style: const TextStyle(
                            fontSize: 15.5,
                            height: 1.75,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'حديث رقم: ${hadith['id']}',
                                style: const TextStyle(
                                  color: Color(0xFFB48425),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
