import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _tempToken;

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
            if (state is OtpSentSuccess) {
              setState(() { _tempToken = state.tempToken; });
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ورود موفقیت‌آمیز"), backgroundColor: Colors.green));
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
            }
          },
          builder: (context, state) {
            final isOtpSent = _tempToken != null;
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.fastfood_rounded, size: 80, color: primaryColor),
                      const SizedBox(height: 24),
                      Text(isOtpSent ? "تایید کد" : "ورود", textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      
                      if (!isOtpSent)
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: "شماره موبایل", prefixIcon: Icon(Icons.phone_iphone)),
                        ),
                      
                      if (isOtpSent)
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 30, letterSpacing: 10, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(labelText: "کد تایید ۶ رقمی"),
                        ),

                      const SizedBox(height: 32),
                      
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            if (isOtpSent) {
                              context.read<AuthBloc>().add(VerifyOtpRequested(
                                mobile: _mobileController.text,
                                token: _tempToken!,
                                code: _codeController.text,
                              ));
                            } else if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(SendOtpRequested(_mobileController.text));
                            }
                          },
                          child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isOtpSent ? "ورود" : "ارسال کد"),
                        ),
                      ),
                      
                      if (isOtpSent)
                        TextButton(
                          onPressed: () => setState(() { _tempToken = null; _codeController.clear(); }),
                          child: const Text("اصلاح شماره موبایل"),
                        ),

                      const Spacer(),
                      if (!isOtpSent)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("حساب کاربری ندارید؟"),
                            TextButton(
                              onPressed: () async {
                                // دریافت توکن از صفحه ثبت‌نام
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage(mobile: _mobileController.text)));
                                if (result is String) {
                                  setState(() { _tempToken = result; });
                                  // نکته: اگر کاربر شماره موبایل را در صفحه ثبت نام عوض کرده باشد، 
                                  // سیستم ما در بلاک تایید به مشکل میخورد. 
                                  // اما فعلا فرض میکنیم شماره همان است.
                                }
                              },
                              child: const Text("ثبت نام کنید", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}