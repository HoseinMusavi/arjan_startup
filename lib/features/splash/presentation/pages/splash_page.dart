import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/pages/login_page.dart'; // ایمپورت صفحه لاگین
import '../bloc/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashBloc>()..add(SplashStarted()),
      child: Scaffold(
        // استفاده از رنگ پس‌زمینه تم برای یکدستی
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocConsumer<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashSuccess) {
              // --- تغییر مهم: هدایت به صفحه لاگین ---
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
          builder: (context, state) {
            // اگر خطایی رخ داد
            if (state is SplashError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        "خطا در ارتباط با سرور",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message, // نمایش متن خطا برای دیباگ (بعدا کاربرپسندش میکنیم)
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // تلاش مجدد
                          context.read<SplashBloc>().add(SplashStarted());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("تلاش مجدد"),
                      )
                    ],
                  ),
                ),
              );
            }
            
            // حالت لودینگ (پیش‌فرض)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // لوگوی برنامه (فعلا آیکون)
                  Icon(
                    Icons.fastfood_rounded, 
                    size: 100, 
                    color: Theme.of(context).primaryColor
                  ),
                  const SizedBox(height: 32),
                  
                  // لودینگ
                  const CircularProgressIndicator(),
                  
                  const SizedBox(height: 16),
                  const Text(
                    "در حال راه‌اندازی...",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}