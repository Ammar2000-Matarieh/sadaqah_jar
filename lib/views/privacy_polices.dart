import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/views/widgets/custom_item.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomItem(text: 'مقدمة'),
            _sectionBody(
              'نحن في تطبيق "صدقة جارية" نحترم خصوصيتك ونلتزم بحمايتها. '
              'توضح هذه السياسة نوع البيانات التي قد يتم جمعها، وكيفية استخدامها.',
            ),

            CustomItem(text: 'البيانات التي لا نقوم بجمعها'),
            _sectionBody(
              'هذا التطبيق لا يطلب تسجيل دخول، ولا يجمع أي معلومات شخصية '
              'مثل الاسم أو البريد الإلكتروني أو رقم الهاتف.',
            ),

            CustomItem(text: 'مصادر المحتوى'),
            _sectionBody(
              'يعرض التطبيق آيات قرآنية وأحاديث نبوية من مصادر إسلامية موثوقة '
              'عبر خدمات API مجانية ومفتوحة المصدر، ولا يتم إرسال أي بيانات '
              'خاصة بالمستخدم إلى هذه الخدمات أثناء الاستخدام.',
            ),

            CustomItem(text: 'الأذونات المستخدمة'),
            _sectionBody(
              'قد يطلب التطبيق إذن الوصول للإنترنت فقط، لعرض المحتوى الديني '
              'وتحديثه بشكل مستمر.',
            ),

            CustomItem(text: 'التعديلات على هذه السياسة'),
            _sectionBody(
              'قد يتم تحديث هذه السياسة من وقت لآخر. يُنصح بمراجعتها بشكل دوري.',
            ),

            CustomItem(text: 'تواصل معنا'),
            _sectionBody(
              'لأي استفسار بخصوص الخصوصية، يمكنك التواصل معنا عبر البريد '
              'الإلكتروني الموضح في صفحة "عن التطبيق".',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionBody(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14.5, height: 1.8, color: Colors.black),
      textAlign: TextAlign.justify,
    );
  }
}
