import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../network/dio_client.dart';
import '../services/session_service.dart';

// Splash Feature
import '../../features/splash/data/repositories/config_repository.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_remote_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Home Feature
import '../../features/home/data/datasources/home_remote_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Profile Feature
import '../../features/profile/data/datasources/profile_remote_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Restaurant Feature
import '../../features/restaurant/data/datasources/restaurant_remote_source.dart';
import '../../features/restaurant/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurant/domain/repositories/restaurant_repository.dart';
import '../../features/restaurant/presentation/bloc/restaurant/restaurant_bloc.dart';

// Cart Feature
import '../../features/cart/data/datasources/cart_remote_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

// Order Feature
import '../../features/orders/data/datasources/order_remote_source.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  debugPrint('🔧 [DI] راه‌اندازی سرویس‌لوکیتور...');

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  debugPrint('✅ [DI] SharedPreferences ثبت شد');

  // Session Service
  getIt.registerLazySingleton<SessionService>(() => SessionService(getIt<SharedPreferences>()));
  debugPrint('✅ [DI] SessionService ثبت شد');

  getIt.registerLazySingleton<DioClient>(() => DioClient());
  debugPrint('✅ [DI] DioClient ثبت شد');

  // ==================== Splash Feature ====================
  getIt.registerLazySingleton<ConfigRepository>(() => ConfigRepositoryImpl(getIt<DioClient>()));
  getIt.registerFactory<SplashBloc>(() => SplashBloc(getIt<ConfigRepository>()));
  debugPrint('✅ [DI] Splash Feature ثبت شد');

  // ==================== Auth Feature ====================
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>(), getIt<SharedPreferences>()),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  debugPrint('✅ [DI] Auth Feature ثبت شد');

  // ==================== Home Feature ====================
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt<DioClient>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  );
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<HomeRepository>()));
  debugPrint('✅ [DI] Home Feature ثبت شد');

  // ==================== Profile Feature ====================
  // 🔥 تغییر مهم: به جای SharedPreferences، از SessionService استفاده می‌کنیم
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<DioClient>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );
  getIt.registerFactory<ProfileBloc>(() => ProfileBloc(getIt<ProfileRepository>()));
  debugPrint('✅ [DI] Profile Feature ثبت شد');

  // ==================== Restaurant Feature ====================
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(getIt<DioClient>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(getIt<RestaurantRemoteDataSource>()),
  );
  getIt.registerFactory<RestaurantBloc>(() => RestaurantBloc(getIt<RestaurantRepository>()));
  debugPrint('✅ [DI] Restaurant Feature ثبت شد');

  // ==================== Cart Feature ====================
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<CartRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CartBloc>(() => CartBloc(getIt<CartRepository>()));
  debugPrint('✅ [DI] Cart Feature ثبت شد');

  // ==================== Order Feature ====================
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderRemoteDataSource>()),
  );
  getIt.registerFactory<OrderBloc>(() => OrderBloc(getIt<OrderRepository>()));
  debugPrint('✅ [DI] Order Feature ثبت شد');

  debugPrint('🔧 [DI] سرویس‌لوکیتور با موفقیت راه‌اندازی شد');
}