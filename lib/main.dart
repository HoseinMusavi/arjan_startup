import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // راه‌اندازی سرویس‌ها (DI)
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استفاده از متد router برای فعال‌سازی GoRouter
    return MaterialApp.router(
      title: 'Arjan Startup',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // تنظیمات GoRouter
      routerConfig: AppRouter.router,
    );
  }
}