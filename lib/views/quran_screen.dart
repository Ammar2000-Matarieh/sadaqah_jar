import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/quran_controller.dart';
import 'package:sadqah_jariyah_app/main.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranController>(context, listen: false).getSurahs();
    });
    return Scaffold(
      backgroundColor: AppColors.whiteColor,

      body: Consumer<QuranController>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF0F4C43)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            itemCount: value.surahs.length,
            itemBuilder: (context, index) {
              final surah = value.surahs[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  shadowColor: Colors.black.withValues(alpha: 0.02),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailsPage(
                            surahNumber: surah['number'],
                            surahName: surah['name'],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0F4C43,
                          ).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF0F4C43,
                            ).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${surah['number']}',
                            style: const TextStyle(
                              color: Color(0xFF0F4C43),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        surah['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'آياتها: ${surah['numberOfAyahs']}  •  ${surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
