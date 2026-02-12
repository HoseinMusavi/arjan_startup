import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_config.dart';
import '../bloc/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashBloc>()..add(SplashStarted()),
      child: Scaffold(
        body: BlocConsumer<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashSuccess) {
              // هدایت به صفحه خانه (فعلا فقط چاپ میکنیم)
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تنظیمات دریافت شد! واحد پول: ${AppConfig().formatPrice(1000)}')),
              );
            }
          },
          builder: (context, state) {
            if (state is SplashError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SplashBloc>().add(SplashStarted());
                      },
                      child: const Text("تلاش مجدد"),
                    )
                  ],
                ),
              );
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اینجا بعدا لوگوی اپ را میگذاریم
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 24),
                  if (state is SplashLoading)
                    const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text("در حال دریافت تنظیمات...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}