import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _mobileController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _tempToken;
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _start = 60;
      _canResend = false;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _canResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            
            if (state is OtpSentSuccess) {
              setState(() {
                _tempToken = state.tempToken;
              });
              _startTimer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('کد تایید ارسال شد'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('خوش آمدید!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // استفاده از go برای رفتن به خانه و پاک کردن پشته
              context.go('/home');
            }
          },
          builder: (context, state) {
            final isOtpSent = _tempToken != null;
            final isLoading = state is AuthLoading;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isOtpSent ? Icons.sms_outlined : Icons.restaurant_menu_rounded,
                              size: 60,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          isOtpSent ? 'کد تایید را وارد کنید' : 'ورود به حساب کاربری',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 22
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isOtpSent 
                              ? 'کد ۶ رقمی به شماره ${_mobileController.text} ارسال شد'
                              : 'برای استفاده از امکانات، شماره موبایل خود را وارد کنید',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 48),

                        if (!isOtpSent)
                          _buildMobileInput(primaryColor),
                        
                        if (isOtpSent)
                          _buildCodeInput(primaryColor),

                        const SizedBox(height: 32),

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () {
                              if (isOtpSent) {
                                context.read<AuthBloc>().add(VerifyOtpRequested(
                                  mobile: _mobileController.text,
                                  token: _tempToken!,
                                  code: _codeController.text,
                                ));
                              } else {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(SendOtpRequested(_mobileController.text));
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text(isOtpSent ? 'تایید و ورود' : 'دریافت کد تایید', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (isOtpSent)
                          Column(
                            children: [
                              if (_canResend)
                                TextButton.icon(
                                  onPressed: isLoading ? null : () {
                                    context.read<AuthBloc>().add(SendOtpRequested(_mobileController.text));
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("ارسال مجدد کد"),
                                )
                              else
                                Text(
                                  "ارسال مجدد کد تا $_start ثانیه دیگر",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _tempToken = null;
                                    _timer?.cancel();
                                    _codeController.clear();
                                  });
                                },
                                child: const Text("تغییر شماره موبایل", style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          ),

                        if (!isOtpSent)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("حساب کاربری ندارید؟", style: TextStyle(color: Colors.grey.shade600)),
                              TextButton(
                                onPressed: () async {
                                  // استفاده از push برای رفتن به ثبت نام و انتظار برای نتیجه
                                  final result = await context.push<String?>('/signup', extra: _mobileController.text);
                                  
                                  if (result != null) {
                                    setState(() {
                                      _tempToken = result;
                                    });
                                    _startTimer();
                                  }
                                },
                                child: const Text("ثبت‌نام کنید", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileInput(Color color) {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      autofocus: true,
      style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
      decoration: InputDecoration(
        labelText: 'شماره موبایل',
        hintText: '09xxxxxxxxx',
        prefixIcon: Icon(Icons.phone_iphone_rounded, color: color),
      ),
      validator: (v) => (v == null || v.length < 10) ? 'شماره موبایل معتبر نیست' : null,
    );
  }

  Widget _buildCodeInput(Color color) {
    return TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      autofocus: true,
      maxLength: 6,
      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'کد تایید',
        counterText: "",
        prefixIcon: Icon(Icons.lock_outline_rounded),
      ),
    );
  }
}