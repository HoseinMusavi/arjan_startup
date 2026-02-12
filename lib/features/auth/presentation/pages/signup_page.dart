import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  final String? mobile;
  const SignupPage({super.key, this.mobile});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.mobile != null) {
      _mobileController.text = widget.mobile!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
            onPressed: () => context.pop(), // بازگشت با GoRouter
          ),
          title: const Text("ثبت‌نام", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpSentSuccess) {
              // بازگرداندن توکن به صفحه لاگین
              context.pop(state.tempToken);
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade600),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "خوش آمدید!",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "لطفاً اطلاعات زیر را برای ایجاد حساب کاربری تکمیل کنید.",
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _fNameController,
                        label: "نام",
                        icon: Icons.person_rounded,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _lNameController,
                        label: "نام خانوادگی",
                        icon: Icons.person_outline_rounded,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _mobileController,
                        label: "شماره موبایل",
                        icon: Icons.phone_android_rounded,
                        inputType: TextInputType.phone,
                        color: primaryColor,
                        validator: (v) => (v == null || v.length < 10) ? 'شماره معتبر نیست' : null,
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(RegisterRequested(
                                firstName: _fNameController.text,
                                lastName: _lNameController.text,
                                mobile: _mobileController.text,
                                password: "Auto", 
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text("ثبت‌نام و دریافت کد", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
      ),
      validator: validator ?? (v) => (v == null || v.isEmpty) ? '$label الزامی است' : null,
    );
  }
}