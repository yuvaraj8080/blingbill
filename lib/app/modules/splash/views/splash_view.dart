import 'package:blingbill/app/constants/app_constants.dart';
import 'package:blingbill/app/global_widgets/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to home or login screen
      Get.offAll(BlingBillApp()); // change as needed
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFCE5B2), // same warm tone as logo bg
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset('assets/icons/app_icon.png', width: 150, height: 150, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(
              'BlingBill',
              style: AppConstants.subheadingStyle.copyWith(fontSize: 32, color: AppConstants.lightSurfaceColor),
            ),
          ],
        ),
      ),
    );
  }
}
