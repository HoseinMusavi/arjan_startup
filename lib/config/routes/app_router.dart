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
import '../../features/profile/presentation/pages/add_edit_address_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';

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

          // تب ۲: سفارشات
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOrdersKey,
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),

          // تب ۳: پروفایل ✅ با تمام مسیرهای زیرمجموعه
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              // صفحه اصلی پروفایل
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
              // ویرایش اطلاعات
              GoRoute(
                path: '/profile/edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfilePage(),
              ),
              // تغییر رمز عبور
              GoRoute(
                path: '/profile/change-password',
                name: 'change-password',
                builder: (context, state) => const ChangePasswordPage(),
              ),
              // کیف پول - خلاصه
              GoRoute(
                path: '/profile/points',
                name: 'points',
                builder: (context, state) => const PointsPage(),
              ),
              // کیف پول - جزئیات (با پارامتر pointType)
              GoRoute(
                path: '/profile/points/details',
                name: 'points-details',
                builder: (context, state) => const PointDetailsPage(),
              ),
              // آدرس‌ها - لیست
              GoRoute(
                path: '/profile/addresses',
                name: 'addresses',
                builder: (context, state) => const AddressesPage(),
              ),
              // آدرس‌ها - افزودن جدید
              GoRoute(
                path: '/profile/addresses/add',
                name: 'add-address',
                builder: (context, state) => const AddEditAddressPage(),
              ),
              // اعلان‌ها
              GoRoute(
                path: '/profile/notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}