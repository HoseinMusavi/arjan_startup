import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  
  String? tempToken;
  bool isOtpSent = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpSentSuccess) {
              setState(() {
                isOtpSent = true;
                tempToken = state.token;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("کد تایید ارسال شد"), backgroundColor: Colors.green),
              );
            }

            if (state is AuthSuccess) {
              context.go('/home');
            }

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_person_outlined, size: 80, color: Colors.orange),
                    const SizedBox(height: 24),
                    const Text(
                      "ورود به حساب کاربری",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 48),

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

                    if (isOtpSent) ...[
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
                      const SizedBox(height: 24),
                    ],

                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () {
                          final mobile = mobileController.text;
                          if (mobile.isEmpty) return;

                          if (isOtpSent) {
                            final otp = otpController.text;
                            if (otp.length < 4) return;
                            context.read<AuthBloc>().add(
                              VerifyOtpRequested(mobile: mobile, otp: otp, token: tempToken!)
                            );
                          } else {
                            context.read<AuthBloc>().add(SendOtpRequested(mobile));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isOtpSent ? "تایید و ورود" : "ارسال کد تایید", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      
                    if (isOtpSent)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isOtpSent = false;
                            otpController.clear();
                            tempToken = null;
                          });
                        },
                        child: const Text("اصلاح شماره موبایل"),
                      ),

                    // ✅ دکمه ثبت نام اضافه شد
                    if (!isOtpSent) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("حساب کاربری ندارید؟"),
                          TextButton(
                            onPressed: () {
                              context.push('/signup', extra: mobileController.text);
                            },
                            child: const Text("ثبت نام کنید", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ]
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