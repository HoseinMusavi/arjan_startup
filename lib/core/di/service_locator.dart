import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../network/dio_client.dart';

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

// Restaurant Feature (بخش جدید اضافه شده)
import '../../features/restaurant/data/datasources/restaurant_remote_source.dart';
import '../../features/restaurant/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurant/domain/repositories/restaurant_repository.dart';
import '../../features/restaurant/presentation/bloc/restaurant_bloc.dart';

// Cart Feature
import '../../features/cart/data/datasources/cart_remote_source.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';


final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ---------------------------------------------------------------------------
  // 1. External (وابستگی‌های خارجی)
  // ---------------------------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // ---------------------------------------------------------------------------
  // 2. Core (هسته)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ---------------------------------------------------------------------------
  // 3. Features - Splash (اسپلش)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<ConfigRepository>(
      () => ConfigRepositoryImpl(getIt<DioClient>()));
  
  getIt.registerFactory<SplashBloc>(
      () => SplashBloc(getIt<ConfigRepository>()));

  // ---------------------------------------------------------------------------
  // 4. Features - Auth (احراز هویت)
  // ---------------------------------------------------------------------------
  // Data Source
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<DioClient>()));

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(), 
        getIt<SharedPreferences>(),
      ));

  // Bloc
  getIt.registerFactory<AuthBloc>(
      () => AuthBloc(getIt<AuthRepository>()));

  // ---------------------------------------------------------------------------
  // 5. Features - Home (خانه)
  // ---------------------------------------------------------------------------
  // Data Source
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // Repository
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  );

  // Bloc
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getIt<HomeRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 6. Features - Profile (پروفایل)
  // ---------------------------------------------------------------------------
  // Data Source 
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      getIt<DioClient>(), 
      getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );

  // Bloc
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getIt<ProfileRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 7. Features - Restaurant Menu (منوی رستوران)
  // ---------------------------------------------------------------------------
  // Data Source
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // Repository
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(getIt<RestaurantRemoteDataSource>()),
  );

  // Bloc (تعریف دقیق نوع برای جلوگیری از خطای GetIt)
  getIt.registerFactory<RestaurantBloc>(
    () => RestaurantBloc(getIt<RestaurantRepository>()),
  );

  // Cart Feature
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<CartRemoteDataSource>()),
  );

  getIt.registerFactory<CartBloc>(
    () => CartBloc(getIt<CartRepository>()),
  );
}