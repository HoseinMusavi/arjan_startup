import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileController = TextEditingController();
  final _codeController = TextEditingController();
  
  // برای ذخیره توکن موقت
  String? _tempToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
            if (state is OtpSentSuccess) {
              _tempToken = state.tempToken;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('کد تایید ارسال شد'), backgroundColor: Colors.green),
              );
            }
            if (state is AuthSuccess) {
              // هدایت به صفحه اصلی
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خوش آمدید!'), backgroundColor: Colors.green),
              );
              // Navigator.pushReplacement...
            }
          },
          builder: (context, state) {
            final isOtpSent = state is OtpSentSuccess || (state is AuthLoading && _tempToken != null);
            
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // لوگو یا متن خوش‌آمد
                    const Text(
                      'ورود به حساب کاربری',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOtpSent 
                          ? 'کد ارسال شده به ${_mobileController.text} را وارد کنید'
                          : 'شماره موبایل خود را وارد کنید',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // فیلد شماره موبایل
                    if (!isOtpSent)
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'شماره موبایل',
                          hintText: '09xxxxxxxxx',
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                      ),

                    // فیلد کد تایید (فقط وقتی کد ارسال شد نمایش داده شود)
                    if (isOtpSent)
                       TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, letterSpacing: 8),
                        decoration: const InputDecoration(
                          labelText: 'کد تایید',
                          hintText: '----',
                        ),
                      ),

                    const Spacer(),

                    // دکمه اصلی
                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (isOtpSent) {
                            // تایید کد
                            context.read<AuthBloc>().add(
                              VerifyOtpRequested(
                                mobile: _mobileController.text,
                                token: _tempToken!,
                                code: _codeController.text,
                              ),
                            );
                          } else {
                            // ارسال درخواست کد
                            if (_mobileController.text.length >= 10) {
                              context.read<AuthBloc>().add(
                                SendOtpRequested(_mobileController.text),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('شماره موبایل صحیح نیست')),
                              );
                            }
                          }
                        },
                        child: Text(isOtpSent ? 'ورود' : 'دریافت کد تایید'),
                      ),
                      
                      if (isOtpSent)
                        TextButton(
                          onPressed: () {
                             // برگشت به مرحله قبل (ریست کردن state باید هندل شود)
                             // فعلا ساده صفحه را ریلود میکنیم یا متغییرها را پاک میکنیم
                          },
                          child: const Text("تغییر شماره موبایل"),
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