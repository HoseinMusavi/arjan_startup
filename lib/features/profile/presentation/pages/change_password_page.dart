import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// صفحه تغییر رمز عبور
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('🔑 [ChangePasswordPage] initState');
    _profileBloc = getIt<ProfileBloc>();
  }

  @override
  void dispose() {
    debugPrint('🔑 [ChangePasswordPage] dispose');
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تغییر رمز عبور'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfilePasswordChangeSuccess) {
              debugPrint('✅ [ChangePasswordPage] Password changed: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                context.pop();
              });
            }
            if (state is ProfileError) {
              debugPrint('❌ [ChangePasswordPage] Error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfilePasswordChangeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تغییر رمز عبور',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'برای حفظ امنیت حساب خود، رمز عبور را به‌طور مرتب تغییر دهید.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildPasswordField(
                        controller: _currentPasswordController,
                        label: 'رمز عبور فعلی',
                        hint: 'رمز عبور فعلی خود را وارد کنید',
                        obscureText: _obscureCurrent,
                        onToggle: () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً رمز عبور فعلی را وارد کنید';
                          }
                          if (value.trim().length < 4) {
                            return 'رمز عبور باید حداقل ۴ کاراکتر باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'رمز عبور جدید',
                        hint: 'رمز عبور جدید را وارد کنید',
                        obscureText: _obscureNew,
                        onToggle: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً رمز عبور جدید را وارد کنید';
                          }
                          if (value.trim().length < 4) {
                            return 'رمز عبور باید حداقل ۴ کاراکتر باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'تکرار رمز عبور جدید',
                        hint: 'رمز عبور جدید را دوباره وارد کنید',
                        obscureText: _obscureConfirm,
                        onToggle: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً رمز عبور جدید را تکرار کنید';
                          }
                          if (value.trim() != _newPasswordController.text.trim()) {
                            return 'رمز عبور با تکرار آن مطابقت ندارد';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'تغییر رمز عبور',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _submitForm() {
    debugPrint('🔑 [ChangePasswordPage] Submit form');
    if (_formKey.currentState!.validate()) {
      _profileBloc.add(
        ProfileChangePasswordRequested(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
          confirmNewPassword: _confirmPasswordController.text.trim(),
        ),
      );
    } else {
      debugPrint('❌ [ChangePasswordPage] Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تمام فیلدها را به‌درستی پر کنید.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}