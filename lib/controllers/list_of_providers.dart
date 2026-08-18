import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sadqah_jariyah_app/controllers/azkar_controller.dart';
import 'package:sadqah_jariyah_app/controllers/bottom_nav_controller.dart';
import 'package:sadqah_jariyah_app/controllers/hadith_controller.dart';
import 'package:sadqah_jariyah_app/controllers/quran_controller.dart';

List<SingleChildWidget> listOfProviders = [
  ChangeNotifierProvider(create: (context) => QuranController(), lazy: true),
  ChangeNotifierProvider(
    create: (context) => BottomNavController(),
    lazy: true,
  ),
  ChangeNotifierProvider(create: (context) => AzkarController(), lazy: true),
  ChangeNotifierProvider(create: (context) => HadithController(), lazy: true),
];
