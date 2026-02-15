import 'package:arjanstartup/core/di/service_locator.dart';
import 'package:arjanstartup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:arjanstartup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProfileBloc>()..add(ProfileRequested())),
        BlocProvider(create: (context) => getIt<AuthBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/login');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("پروفایل کاربری"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              String displayName = "کاربر مهمان";
              String points = "0";
              String avatarUrl = "";
              bool hasError = false;

              if (state is ProfileLoaded) {
                final fName = state.profile.firstName;
                final lName = state.profile.lastName;
                final phone = state.profile.phone;

                // ✅ لاجیک جدید: اولویت با نام، اگر نبود شماره تماس
                if (fName.isNotEmpty || lName.isNotEmpty) {
                  displayName = "$fName $lName";
                } else if (phone.isNotEmpty) {
                  displayName = phone;
                }
                
                points = state.profile.points.toString();
                avatarUrl = state.profile.avatar;
              } else if (state is ProfileError) {
                hasError = true;
                displayName = "خطا در دریافت اطلاعات";
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 3),
                        image: (avatarUrl.isNotEmpty) 
                          ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                          : null,
                      ),
                      child: avatarUrl.isEmpty 
                        ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                        : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      displayName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr, // برای نمایش صحیح شماره تماس
                    ),
                    const SizedBox(height: 8),
                    
                    if (!hasError)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "$points امتیاز",
                              style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 40),

                    _buildProfileItem(Icons.shopping_bag_outlined, "سفارش‌های من", () {}),
                    _buildProfileItem(Icons.favorite_outline, "علاقه‌مندی‌ها", () {}),
                    _buildProfileItem(Icons.location_on_outlined, "آدرس‌های من", () {}),
                    _buildProfileItem(Icons.support_agent, "پشتیبانی", () {}),
                    
                    const Divider(height: 40),
                    
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text("خروج از حساب کاربری", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("خروج"),
        content: const Text("آیا مطمئن هستید که می‌خواهید خارج شوید؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("انصراف"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogout());
            },
            child: const Text("بله، خروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}