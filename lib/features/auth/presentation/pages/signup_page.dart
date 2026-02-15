import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  final String? mobileNumber;

  const SignupPage({super.key, this.mobileNumber});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  late TextEditingController mobileController;
  final TextEditingController passwordController = TextEditingController();

  // برای کنترل وضعیت ارسال کد
  bool isOtpSent = false;
  final TextEditingController otpController = TextEditingController();
  String? tempToken; // نگهداری توکن موقت

  @override
  void initState() {
    super.initState();
    mobileController = TextEditingController(text: widget.mobileNumber ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text("ثبت نام"), centerTitle: true),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // ۱. کد ارسال شد
            if (state is OtpSentSuccess) {
              setState(() {
                isOtpSent = true;
                tempToken = state.token;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("کد تایید ارسال شد"), backgroundColor: Colors.green),
              );
            }

            // ۲. موفقیت نهایی (ورود)
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("خوش آمدید!"), backgroundColor: Colors.green),
              );
              context.go('/home');
            }

            // ۳. خطا
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "ایجاد حساب جدید",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    // شماره موبایل
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      enabled: !isOtpSent,
                      decoration: InputDecoration(
                        labelText: "شماره موبایل",
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // اگر هنوز کد ارسال نشده، فیلدهای نام و رمز را نشان بده (جهت پر کردن)
                    // نکته: در این API فعلاً فقط موبایل اولویت دارد، اما فیلدها را نگه می‌داریم
                    if (!isOtpSent) ...[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "نام و نام خانوادگی",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "رمز عبور",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else ...[
                      // فیلد کد تایید
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: "کد تایید پیامک شده",
                          prefixIcon: const Icon(Icons.sms),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          counterText: "",
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),

                    // دکمه عملیات
                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () {
                          final mobile = mobileController.text;
                          
                          if (mobile.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("لطفاً شماره موبایل را وارد کنید")),
                            );
                            return;
                          }

                          if (isOtpSent) {
                            // مرحله دوم: تایید کد
                            final otp = otpController.text;
                            if (otp.length < 4) return;
                            
                            // فراخوانی متد تایید
                            context.read<AuthBloc>().add(
                              VerifyOtpRequested(mobile: mobile, otp: otp, token: tempToken!)
                            );
                          } else {
                            // مرحله اول: ارسال کد (شروع ثبت نام)
                            // از SendOtpRequested استفاده می‌کنیم چون AuthRegister حذف شده
                            context.read<AuthBloc>().add(SendOtpRequested(mobile));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isOtpSent ? "تایید نهایی" : "دریافت کد تایید", style: const TextStyle(fontSize: 16)),
                      ),
                      
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text("قبلاً ثبت نام کرده‌اید؟ ورود"),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}