import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ایمپورت‌های ضروری
import '../../core/di/service_locator.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/main/presentation/pages/main_wrapper.dart';
// ایمپورت صفحه پروفایل که الان تصحیح کردیم
import '../../features/profile/presentation/bloc/pages/profile_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellNavigatorLocationsKey = GlobalKey<NavigatorState>(debugLabel: 'shellLocations');
  static final GlobalKey<NavigatorState> _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    redirect: (BuildContext context, GoRouterState state) {
      final prefs = getIt<SharedPreferences>();
      final bool isLoggedIn = prefs.containsKey('client_token');
      final String location = state.uri.toString();
      final bool isLoggingIn = location == '/login';
      final bool isSigningUp = location == '/signup';
      final bool isSplash = location == '/';

      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isSplash) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return '/home';
      }

      return null;
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
          final mobile = state.extra as String?;
          return SignupPage(mobileNumber: mobile);
        },
      ),

      // بدنه اصلی همراه با تب‌های پایین (Bottom Navigation Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // تب ۱: خانه
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          
          // تب ۲: مکان‌ها (هنوز فایلش را نساخته‌اید، موقت می‌گذاریم)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLocationsKey,
            routes: [
              GoRoute(
                path: '/locations',
                name: 'locations',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('صفحه مکان‌ها به زودی...')),
                ),
              ),
            ],
          ),

          // تب ۳: پروفایل
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}