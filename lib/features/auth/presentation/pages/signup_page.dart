import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  final String? mobileNumber;

  const SignupPage({super.key, this.mobileNumber});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  
  late final AuthBloc _authBloc;
  bool _isLoading = false;
  bool _agreeTerms = false;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty) {
      _mobileController.text = widget.mobileNumber!;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً قوانین را بپذیرید'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    _authBloc.add(CreateAccountRequested(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobile: _mobileController.text.trim(),
      lat: 30.5882768,
      lng: 50.2575974,
    ));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);
    const Color bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('ثبت‌نام', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: (context, state) {
          setState(() => _isLoading = false);
          
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ثبت‌نام با موفقیت انجام شد'), backgroundColor: Colors.green),
            );
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // نام
                const Text('نام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'مثال: علی',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'لطفاً نام خود را وارد کنید' : null,
                ),
                const SizedBox(height: 16),

                // نام خانوادگی
                const Text('نام خانوادگی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'مثال: احمدی',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'لطفاً نام خانوادگی خود را وارد کنید' : null,
                ),
                const SizedBox(height: 16),

                // شماره موبایل
                const Text('شماره موبایل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'مثال: 09123456789',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'لطفاً شماره موبایل را وارد کنید';
                    if (value.length < 11) return 'شماره موبایل باید ۱۱ رقم باشد';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // پذیرش قوانین
                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    Expanded(
                      child: Text(
                        'قوانین و مقررات را می‌پذیرم',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // دکمه ثبت‌نام
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ثبت‌نام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),
                
                // لینک برگشت به لاگین
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('حساب کاربری دارید؟', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('ورود', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}