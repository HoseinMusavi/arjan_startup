import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  // کلیدهای نویگیتور برای دسترسی‌های سطح پایین در صورت نیاز
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // نقطه شروع برنامه
    debugLogDiagnostics: true, // نمایش لاگ‌های تغییر مسیر در کنسول
    
    // --- لاجیک هوشمند ریدایرکت (Redirection Logic) ---
    // این تابع قبل از هر تغییر مسیری اجرا می‌شود تا وضعیت کاربر را چک کند
    redirect: (BuildContext context, GoRouterState state) {
      final prefs = getIt<SharedPreferences>();
      
      // ۱. آیا کاربر توکن دارد؟ (لاگین است؟)
      final bool isLoggedIn = prefs.containsKey('client_token');
      
      // ۲. کاربر الان کجاست؟
      final bool isLoggingIn = state.uri.toString() == '/login';
      final bool isSigningUp = state.uri.toString() == '/signup';
      final bool isSplash = state.uri.toString() == '/';

      // ۳. اگر کاربر لاگین نیست و می‌خواهد به صفحات داخلی برود (بجز لاگین/ثبت‌نام/اسپلش)
      // او را به صفحه لاگین هدایت کن
      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isSplash) {
        return '/login';
      }

      // ۴. اگر کاربر لاگین است و به صفحه لاگین یا اسپلش می‌آید
      // او را مستقیماً به خانه بفرست
      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return '/home';
      }

      // در غیر این صورت، اجازه بده به مسیر درخواستی برود
      return null;
    },

    routes: [
      // اسپلش اسکرین
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // صفحه ورود
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // صفحه ثبت‌نام
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          // دریافت پارامتر موبایل که از صفحه لاگین پاس داده می‌شود
          final mobile = state.extra as String?; 
          return SignupPage(mobile: mobile);
        },
      ),

      // صفحه اصلی (خانه)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}