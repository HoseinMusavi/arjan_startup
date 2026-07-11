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
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/points_page.dart';
import '../../features/profile/presentation/pages/point_details_page.dart';
import '../../features/profile/presentation/pages/addresses_page.dart';
import '../../features/profile/presentation/pages/address_picker_map_page.dart'; // ✅ تغییر
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = 
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    
    redirect: (BuildContext context, GoRouterState state) {
      final prefs = getIt<SharedPreferences>();
      final String? token = prefs.getString('client_token');
      final bool isLoggedIn = token != null && token.isNotEmpty;
      
      final String location = state.matchedLocation;
      
      debugPrint('📍 [ROUTER] مسیر: $location');
      debugPrint('🔐 [ROUTER] وضعیت لاگین: $isLoggedIn');
      
      // ✅ اگر در splash هستیم، هیچ redirect انجام نده
      if (location == '/splash') {
        debugPrint('⏳ [ROUTER] در صفحه اسپلش، صبر می‌کنیم...');
        return null;
      }
      
      // ✅ مسیرهای عمومی (نیاز به لاگین ندارند)
      final bool isPublicRoute = location == '/' || 
                                  location == '/login' || 
                                  location == '/signup';
      
      // ✅ مسیرهای محافظت شده (نیاز به لاگین دارند)
      final bool isProtectedRoute = location.startsWith('/home') || 
                                    location.startsWith('/profile') ||
                                    location.startsWith('/orders') ||
                                    location.startsWith('/supermarket') ||
                                    location.startsWith('/cart');

      // ✅ اگر لاگین نیست و به مسیر محافظت شده می‌رود → برو لاگین
      if (!isLoggedIn && isProtectedRoute) {
        debugPrint('⛔ [ROUTER] کاربر لاگین نیست → هدایت به لاگین');
        return '/login';
      }

      // ✅ اگر لاگین است و به مسیر عمومی می‌رود → برو خانه
      if (isLoggedIn && isPublicRoute) {
        debugPrint('✅ [ROUTER] کاربر لاگین است → هدایت به خانه');
        return '/home';
      }

      return null;
    },

    routes: [
      // ============ مسیرهای عمومی ============
      GoRoute(
        path: '/splash',
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

      // ============ مسیرهای محافظت شده ============
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),

      // ============ Shell Route با تب‌ها ============
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ChangeNotifierProvider(
            create: (_) => StoreProvider(),
            child: MainWrapper(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/supermarket',
                name: 'supermarket',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
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
      
      // ============ مسیرهای زیرمجموعه پروفایل ============
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/profile/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/profile/points',
        name: 'points',
        builder: (context, state) => const PointsPage(),
      ),
      GoRoute(
        path: '/profile/points/details',
        name: 'points-details',
        builder: (context, state) => const PointDetailsPage(),
      ),
      GoRoute(
        path: '/profile/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesPage(),
      ),
      // ✅ تغییر: استفاده از AddressPickerMapPage
      GoRoute(
        path: '/profile/addresses/add',
        name: 'add-address',
        builder: (context, state) => const AddressPickerMapPage(),
      ),
      GoRoute(
        path: '/profile/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'صفحه مورد نظر یافت نشد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'بازگشت به خانه',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ============ متدهای کمکی ============
  static void goTo(String location, {Object? extra}) {
    router.go(location, extra: extra);
  }

  static void pushTo(String location, {Object? extra}) {
    router.push(location, extra: extra);
  }

  static void pop<T extends Object?>([T? result]) {
    try {
      if (router.canPop()) {
        router.pop(result);
      } else {
        router.go('/login');
      }
    } catch (e) {
      debugPrint('⚠️ [ROUTER] خطا در pop: $e');
      router.go('/login');
    }
  }

  static void goHome() {
    router.go('/home');
  }

  static void goToLogin() {
    router.go('/login');
  }

  static void goToSignup({String? mobile}) {
    router.go('/signup', extra: mobile);
  }

  static void logoutAndGoToLogin() {
    final prefs = getIt<SharedPreferences>();
    prefs.remove('client_token');
    prefs.remove('user_token');
    prefs.remove('user_first_name');
    prefs.remove('user_last_name');
    prefs.remove('user_phone');
    
    router.go('/login');
  }
}