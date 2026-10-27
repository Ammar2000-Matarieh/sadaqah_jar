import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/theme_controller.dart';
import 'package:sadqah_jariyah_app/controllers/list_of_providers.dart';
import 'package:sadqah_jariyah_app/utils/extensions/responsive_widget.dart';
import 'package:sadqah_jariyah_app/utils/routes/app_routes.dart';
import 'package:sadqah_jariyah_app/utils/routes/routes_names.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_theme.dart';

class ReligiousApp extends StatelessWidget {
  const ReligiousApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: listOfProviders,
      child: Responsive(
        child: Consumer<ThemeController>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              navigatorKey: AppRoutes.navigatorKey,
              initialRoute: RoutesNames.initialRoute,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              debugShowCheckedModeBanner: false,
              title: 'صدقة جارية',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeProvider.themeMode,
            );
          },
        ),
      ),
    );
  }
}
