import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (widget.mobile != null) _mobileController.text = widget.mobile!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpSentSuccess) {
              // وقتی ثبت‌نام موفق بود و کد ارسال شد، توکن را به صفحه لاگین برمی‌گردانیم
              Navigator.pop(context, state.tempToken);
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ثبت‌نام کاربر جدید", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    TextFormField(controller: _fNameController, decoration: const InputDecoration(labelText: "نام")),
                    const SizedBox(height: 16),
                    TextFormField(controller: _lNameController, decoration: const InputDecoration(labelText: "نام خانوادگی")),
                    const SizedBox(height: 16),
                    TextFormField(controller: _mobileController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "شماره موبایل")),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
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
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("تایید و ادامه"),
                      ),
                    ),
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