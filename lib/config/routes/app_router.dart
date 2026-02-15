import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  // کلید نویگیتور برای کنترل وضعیت
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // --- لاجیک ریدایرکت (هدایت خودکار) ---
    redirect: (BuildContext context, GoRouterState state) {
      final prefs = getIt<SharedPreferences>();
      
      // ۱. آیا کاربر لاگین است؟
      final bool isLoggedIn = prefs.containsKey('client_token');
      
      // ۲. مسیر فعلی
      final String location = state.uri.toString();
      final bool isLoggingIn = location == '/login';
      final bool isSigningUp = location == '/signup';
      final bool isSplash = location == '/';

      // ۳. اگر لاگین نیست و می‌خواهد به صفحات داخلی (مثل خانه) برود -> برو به لاگین
      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isSplash) {
        return '/login';
      }

      // ۴. اگر لاگین است و در صفحه ورود یا اسپلش است -> برو به خانه
      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return '/home';
      }

      return null; // تغییر مسیر لازم نیست
    },

    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          // دریافت شماره موبایل از صفحه قبل
          final mobile = state.extra as String?;
          // ✅ اصلاح شد: استفاده از mobileNumber (نام صحیح پارامتر در SignupPage)
          return SignupPage(mobileNumber: mobile);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}