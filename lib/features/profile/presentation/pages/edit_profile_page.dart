import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// صفحه ویرایش اطلاعات کاربر
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // کنترلرهای فیلدها
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // ✅ نمونه ProfileBloc از GetIt
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('📝 [EditProfilePage] initState');

    // دریافت نمونه از GetIt
    _profileBloc = getIt<ProfileBloc>();

    // مقداردهی اولیه کنترلرها با اطلاعات فعلی پروفایل
    final state = _profileBloc.state;
    if (state is ProfileLoaded) {
      final profile = state.profile;
      _firstNameController = TextEditingController(text: profile.firstName ?? '');
      _lastNameController = TextEditingController(text: profile.lastName ?? '');
      _phoneController = TextEditingController(text: profile.contactPhone ?? '');
      _emailController = TextEditingController(text: profile.emailAddress ?? '');
    } else {
      // در صورت عدم وجود پروفایل، کنترلرها را خالی ایجاد می‌کنیم
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
    }

    debugPrint('📝 [EditProfilePage] Controllers initialized');
  }

  @override
  void dispose() {
    debugPrint('📝 [EditProfilePage] dispose - cleaning controllers');
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ارائه ProfileBloc به درخت ویجت این صفحه
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ویرایش اطلاعات'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          actions: [
            // دکمه ذخیره در AppBar
            TextButton(
              onPressed: _submitForm,
              child: const Text(
                'ذخیره',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            // وقتی ویرایش با موفقیت انجام شد
            if (state is ProfileUpdateSuccess) {
              debugPrint('✅ [EditProfilePage] Profile updated successfully: ${state.message}');
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

            // اگر خطا رخ داد
            if (state is ProfileError) {
              debugPrint('❌ [EditProfilePage] Error: ${state.message}');
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
              if (state is ProfileUpdateLoading) {
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
                        'اطلاعات خود را به‌روز کنید',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'فیلدهای مورد نیاز را پر کنید و روی دکمه ذخیره کلیک کنید.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // فیلد نام
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'نام',
                        hint: 'نام خود را وارد کنید',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً نام خود را وارد کنید';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // فیلد نام خانوادگی
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'نام خانوادگی',
                        hint: 'نام خانوادگی خود را وارد کنید',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً نام خانوادگی خود را وارد کنید';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // فیلد شماره تماس
                      _buildTextField(
                        controller: _phoneController,
                        label: 'شماره تماس',
                        hint: '۰۹۱۲۳۴۵۶۷۸۹',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً شماره تماس خود را وارد کنید';
                          }
                          if (value.trim().length != 11) {
                            return 'شماره تماس باید ۱۱ رقم باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // فیلد ایمیل
                      _buildTextField(
                        controller: _emailController,
                        label: 'ایمیل (اختیاری)',
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'لطفاً یک ایمیل معتبر وارد کنید';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // دکمه ذخیره
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
                            'ذخیره تغییرات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // دکمه تغییر رمز عبور
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            debugPrint('🔑 [EditProfilePage] Navigate to ChangePassword');
                            context.push('/profile/change-password');
                          },
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: const Text('تغییر رمز عبور'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
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

  /// ویجت فیلد ورودی با طراحی استاندارد
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange.shade300),
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

  /// ارسال فرم برای بروزرسانی
  void _submitForm() {
    debugPrint('📤 [EditProfilePage] Submit form');
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();

      debugPrint('📤 [EditProfilePage] Sending: firstName=$firstName, lastName=$lastName, phone=$phone, email=$email');

      // ارسال رویداد بروزرسانی به Bloc (با استفاده از _profileBloc)
      _profileBloc.add(
        ProfileUpdateRequested(
          firstName: firstName,
          lastName: lastName,
          contactPhone: phone,
          emailAddress: email,
        ),
      );
    } else {
      debugPrint('❌ [EditProfilePage] Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تمام فیلدهای اجباری را به‌درستی پر کنید.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}