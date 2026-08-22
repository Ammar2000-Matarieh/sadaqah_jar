import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/quran_controller.dart';

class ReciterBottomSheet extends StatelessWidget {
  const ReciterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<QuranController>(
          builder: (context, controller, _) {
            if (controller.isRecitersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.reciters.isEmpty) {
              return const Center(child: Text('تعذر تحميل قائمة القراء'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'اختر القارئ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: controller.reciters.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final reciter = controller.reciters[index];
                      final identifier = reciter.identifier;
                      final isSelected =
                          controller.selectedReciter == identifier;

                      return ListTile(
                        title: Text(
                          reciter.name ?? '',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              )
                            : null,
                        onTap: () {
                          controller.setReciter(identifier);
                          Navigator.pop(context);
                        },
                      );
                    },
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
