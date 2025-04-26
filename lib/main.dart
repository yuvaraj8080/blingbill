import 'package:blingbill/app/bindings/app_bindings.dart';
import 'package:blingbill/app/services/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/constants/app_constants.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).catchError((e) {
    debugPrint('Error setting orientation: $e');
  });

  Get.put(ThemeController(), permanent: true);
  runApp(const SmartBillMainApp());
}

class SmartBillMainApp extends StatelessWidget {
  const SmartBillMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.fadeIn,
        theme: themeController.themeMode == ThemeMode.dark ? AppConstants.getDarkTheme() : AppConstants.getLightTheme(),
        themeMode: themeController.themeMode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
        getPages: AppPages.pages,
        initialRoute: Routes.INITIAL,
        initialBinding: AppBindings(),
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.1);
          return MediaQuery(
            data: mediaQueryData.copyWith(textScaler: TextScaler.linear(scale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
