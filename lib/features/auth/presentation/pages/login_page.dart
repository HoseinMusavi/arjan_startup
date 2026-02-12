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
  
  // برای ذخیره توکن موقت
  String? _tempToken;

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استفاده از تم تعریف شده در برنامه
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white, // پس‌زمینه سفید برای ظاهری تمیز
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            if (state is OtpSentSuccess) {
              setState(() {
                _tempToken = state.tempToken;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('کد تایید ارسال شد'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('خوش آمدید!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              // در اینجا می‌توانید نویگیشن به صفحه اصلی را انجام دهید
            }
          },
          builder: (context, state) {
            final isOtpSent = state is OtpSentSuccess || (state is AuthLoading && _tempToken != null);
            final isLoading = state is AuthLoading;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(), // بستن کیبورد با لمس صفحه
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          
                          // آیکون بالای صفحه با کانتینر گرد و رنگ ملایم
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isOtpSent ? Icons.sms_outlined : Icons.lock_person_rounded,
                                size: 64,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Text(
                            isOtpSent ? 'تایید شماره موبایل' : 'ورود به حساب کاربری',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 24,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            isOtpSent 
                                ? 'کد تایید ارسال شده به ${_mobileController.text} را وارد کنید'
                                : 'برای استفاده از خدمات، شماره موبایل خود را وارد کنید',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          
                          const SizedBox(height: 40),

                          // انیمیشن تغییر بین فیلد موبایل و فیلد کد
                          AnimatedCrossFade(
                            firstChild: _buildMobileInput(primaryColor),
                            secondChild: _buildCodeInput(primaryColor),
                            crossFadeState: isOtpSent ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),

                          const SizedBox(height: 32),

                          // دکمه اصلی
                          SizedBox(
                            height: 56, // ارتفاع استاندارد و مناسب برای لمس
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (isOtpSent) {
                                  _onVerifyPressed(context);
                                } else {
                                  _onSendOtpPressed(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24, 
                                      width: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                    )
                                  : Text(
                                      isOtpSent ? 'ورود' : 'دریافت کد تایید',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // دکمه‌های پایین صفحه
                          if (isOtpSent)
                            TextButton.icon(
                              onPressed: isLoading ? null : () {
                                 // بازگشت به حالت اول (ریست صفحه)
                                 Navigator.pushReplacement(
                                   context, 
                                   PageRouteBuilder(
                                     pageBuilder: (_, __, ___) => const LoginPage(),
                                     transitionDuration: Duration.zero,
                                   )
                                 );
                              },
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text("تغییر شماره موبایل"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),

                          if (!isOtpSent)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("حساب کاربری ندارید؟", style: TextStyle(color: Colors.grey[600])),
                                TextButton(
                                  onPressed: isLoading ? null : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => SignupPage(mobile: _mobileController.text)),
                                    );
                                  },
                                  child: const Text("ثبت نام کنید", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                        ],
                      ),
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

  // ویجت فیلد ورودی موبایل
  Widget _buildMobileInput(Color color) {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      style: const TextStyle(fontSize: 18, letterSpacing: 2, fontFamily: 'Arial'), // فونت اعداد خواناتر
      decoration: InputDecoration(
        labelText: 'شماره موبایل',
        hintText: '09xxxxxxxxx',
        counterText: "", // حذف شمارنده کاراکتر
        prefixIcon: Icon(Icons.phone_android_rounded, color: color),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'لطفا شماره موبایل را وارد کنید';
        if (value.length < 10) return 'شماره موبایل صحیح نیست';
        return null;
      },
    );
  }

  // ویجت فیلد ورودی کد تایید
  Widget _buildCodeInput(Color color) {
    return Column(
      children: [
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.w600, fontFamily: 'Arial'),
          decoration: InputDecoration(
            hintText: '- - - -',
            counterText: "",
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _onSendOtpPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SendOtpRequested(_mobileController.text),
      );
    }
  }

  void _onVerifyPressed(BuildContext context) {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا کد تایید را وارد کنید')),
      );
      return;
    }
    
    if (_tempToken != null) {
      context.read<AuthBloc>().add(
        VerifyOtpRequested(
          mobile: _mobileController.text,
          token: _tempToken!,
          code: _codeController.text,
        ),
      );
    }
  }
}