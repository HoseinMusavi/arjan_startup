import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/service_locator.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Arjan Startup',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // ✅ نام صحیح کلاس و متغیر روتر در اینجا قرار داده شد
      routerConfig: AppRouter.router,
      
      // تنظیمات راست‌چین (RTL) و زبان فارسی
      locale: const Locale('fa', 'IR'), 
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}