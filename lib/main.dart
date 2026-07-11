import 'package:arjan_startup/core/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ تنظیمات اولیه
  await setupServiceLocator();
  await getIt<SessionService>().initDeviceId();

  final prefs = await SharedPreferences.getInstance();
  final existingToken = prefs.getString('client_token') ?? prefs.getString('user_token');
  if (existingToken != null && existingToken.isNotEmpty) {
    await getIt<SessionService>().setUserToken(existingToken);
    debugPrint('✅ توکن موجود به SessionService منتقل شد: ${existingToken.substring(0, existingToken.length > 10 ? 10 : existingToken.length)}...');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'ارجان اپ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
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
      ),
    );
  }
}