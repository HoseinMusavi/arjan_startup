import 'package:arjanstartup/features/home/data/datasources/home_remote_source.dart';
import 'package:arjanstartup/features/home/data/repositories/home_repository_impl.dart';
import 'package:arjanstartup/features/home/domain/repositories/home_repository.dart';
import 'package:arjanstartup/features/home/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../features/splash/data/repositories/config_repository.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_source.dart'; // جدید
import '../../features/auth/data/repositories/auth_repository_impl.dart'; // جدید
import '../../features/auth/domain/repositories/auth_repository.dart'; // جدید
import '../../features/auth/presentation/bloc/auth_bloc.dart'; // جدید

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  
  // 2. Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // 3. Features - Splash
  getIt.registerLazySingleton<ConfigRepository>(
      () => ConfigRepositoryImpl(getIt<DioClient>()));
  getIt.registerFactory<SplashBloc>(
      () => SplashBloc(getIt<ConfigRepository>()));

  // 4. Features - Auth (بخش جدید)
  // ابتدا DataSource را ثبت می‌کنیم
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<DioClient>()));

  // سپس Repository را ثبت می‌کنیم (توجه کنید که ورودی‌هایش را از GetIt می‌گیرد)
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(), 
        getIt<SharedPreferences>()
      ));

  // در نهایت Bloc را ثبت می‌کنیم
  getIt.registerFactory<AuthBloc>(
      () => AuthBloc(getIt<AuthRepository>()));


      // --- Home Feature ---
  // 1. Data Source
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt()),
  );

  // 2. Repository
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt()),
  );

  // 3. Bloc
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getIt()),
  );
}