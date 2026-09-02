import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/controllers/list_of_providers.dart';
import 'package:sadqah_jariyah_app/utils/extensions/responsive_widget.dart';
import 'package:sadqah_jariyah_app/utils/routes/app_routes.dart';
import 'package:sadqah_jariyah_app/utils/routes/routes_names.dart';

class ReligiousApp extends StatelessWidget {
  const ReligiousApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: listOfProviders,
      child: Responsive(
        child: MaterialApp(
          navigatorKey: AppRoutes.navigatorKey,
          initialRoute: RoutesNames.initialRoute,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          debugShowCheckedModeBanner: false,
          title: 'صدقة جارية',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
              primary: AppColors.primaryColor,
              secondary: AppColors.secColor,
            ),
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
