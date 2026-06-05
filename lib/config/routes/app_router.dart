import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/providers/store_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/main/presentation/pages/main_wrapper.dart';
import '../../features/profile/presentation/bloc/pages/profile_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart'; // ✅ اضافه شد

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellNavigatorSupermarketKey = GlobalKey<NavigatorState>(debugLabel: 'shellSupermarket');
  static final GlobalKey<NavigatorState> _shellNavigatorOrdersKey = GlobalKey<NavigatorState>(debugLabel: 'shellOrders');
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ChangeNotifierProvider(
            create: (_) => StoreProvider(),
            child: MainWrapper(navigationShell: navigationShell),
          );
        },
        branches: [
          // تب ۰: رستوران‌ها
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
          
          // تب ۱: سوپرمارکت (همون صفحه خانه ولی با فیلتر)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSupermarketKey,
            routes: [
              GoRoute(
                path: '/supermarket',
                name: 'supermarket',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // تب ۲: سفارشات ✅ اصلاح شده
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOrdersKey,
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrdersPage(), // ✅ جایگزین placeholder
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