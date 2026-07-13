import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sadqah_jariyah_app/controllers/quran_controller.dart';

List<SingleChildWidget> listOfProviders = [
  ChangeNotifierProvider(create: (context) => QuranController(), lazy: true),
];
