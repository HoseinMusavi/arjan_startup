import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'config/theme/app_theme.dart'; // ایمپورت جدید

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arjan Startup',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // راست‌چین سراسری
          child: child!,
        );
      },
      theme: AppTheme.lightTheme, // استفاده از تم جدید
      home: const SplashPage(),
    );
  }
}