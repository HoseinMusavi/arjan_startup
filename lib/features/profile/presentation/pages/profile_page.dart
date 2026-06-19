import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// صفحه اصلی پروفایل کاربر
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ✅ نمونه‌های Bloc را مستقیماً از GetIt می‌گیریم
  late final ProfileBloc _profileBloc;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 [ProfilePage] initState - getting Bloc instances');

    // دریافت نمونه‌ها از GetIt
    _profileBloc = getIt<ProfileBloc>();
    _authBloc = getIt<AuthBloc>();

    // ارسال رویداد بارگذاری پروفایل (مستقیماً از خود Bloc)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('📱 [ProfilePage] Sending ProfileRequested event');
        _profileBloc.add(const ProfileRequested());
      }
    });
  }

  @override
  void dispose() {
    debugPrint('📱 [ProfilePage] dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ارائه Blocها به درخت ویجت با استفاده از نمونه‌های موجود
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _authBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            debugPrint('🚪 [ProfilePage] AuthInitial detected - navigating to login');
            context.go('/login');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text(
              'پروفایل کاربری',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  debugPrint('⚙️ [ProfilePage] Settings button pressed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تنظیمات در حال توسعه...')),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              debugPrint('🔄 [ProfilePage] BlocBuilder state: $state');

              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProfileError) {
                return _buildErrorWidget(context, state.message);
              }

              if (state is ProfileLoaded) {
                return _buildProfileContent(context, state.profile);
              }

              // حالت‌های دیگر (مثلاً ProfileInitial) - نمایش placeholder
              return const Center(child: Text('در حال بارگذاری...'));
            },
          ),
        ),
      ),
    );
  }

  /// ویجت نمایش خطا با دکمه تلاش مجدد
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری پروفایل',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🔄 [ProfilePage] Retry button pressed');
              // ✅ استفاده از _profileBloc به جای context.read
              _profileBloc.add(const ProfileRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  /// محتوای اصلی پروفایل (پس از بارگذاری موفق)
  Widget _buildProfileContent(BuildContext context, dynamic profile) {
    // profile از نوع ProfileDto است
    final avatar = profile.avatar ?? '';
    final firstName = profile.firstName ?? '';
    final lastName = profile.lastName ?? '';
    final fullName = profile.fullName ?? '$firstName $lastName';
    final contactPhone = profile.contactPhone ?? '';
    final emailAddress = profile.emailAddress ?? '';
    final hasAvatar = avatar.isNotEmpty;

    debugPrint('📱 [ProfilePage] Rendering profile for: $fullName ($contactPhone)');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== هدر پروفایل ====================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // آواتار
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 3,
                        ),
                        image: hasAvatar
                            ? DecorationImage(
                                image: NetworkImage(avatar),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: !hasAvatar
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    // دکمه تغییر آواتار (برای آینده)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // نام کامل
                Text(
                  fullName.isNotEmpty ? fullName : 'کاربر گرامی',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // شماره تماس
                if (contactPhone.isNotEmpty)
                  Text(
                    contactPhone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 8),

                // ایمیل (در صورت وجود)
                if (emailAddress.isNotEmpty)
                  Text(
                    emailAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 12),

                // امتیاز (با توجه به اینکه فعلاً از ProfileDto امتیاز نداریم، یک مقدار پیش‌فرض)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '۰ امتیاز',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ==================== لیست منوها ====================
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.edit_outlined,
                  iconColor: Colors.blue,
                  title: 'ویرایش اطلاعات',
                  subtitle: 'نام، شماره، ایمیل',
                  onTap: () {
                    debugPrint('📝 [ProfilePage] Navigate to EditProfile');
                    context.push('/profile/edit');
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.green,
                  title: 'کیف پول',
                  subtitle: 'موجودی و تراکنش‌ها',
                  onTap: () {
                    debugPrint('💰 [ProfilePage] Navigate to Points');
                    context.push('/profile/points');
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.purple,
                  title: 'آدرس‌های من',
                  subtitle: 'مدیریت آدرس‌ها',
                  onTap: () {
                    debugPrint('📍 [ProfilePage] Navigate to Addresses');
                    context.push('/profile/addresses');
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: 'اعلان‌ها',
                  subtitle: 'پیام‌ها و اطلاعیه‌ها',
                  onTap: () {
                    debugPrint('🔔 [ProfilePage] Navigate to Notifications');
                    context.push('/profile/notifications');
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.support_outlined,
                  iconColor: Colors.teal,
                  title: 'پشتیبانی',
                  subtitle: 'ارتباط با ما',
                  onTap: () {
                    debugPrint('📞 [ProfilePage] Navigate to Support');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('پشتیبانی: ۰۲۱-۱۲۳۴۵۶۷۸')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ==================== دکمه خروج ====================
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildMenuItem(
              context,
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'خروج از حساب کاربری',
              subtitle: 'اطلاعات شما حذف نمی‌شود',
              onTap: () => _showLogoutDialog(context),
              isLogout: true,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ویجت آیتم منو
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isLogout ? Colors.red.shade300 : Colors.grey.shade400,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  /// جداکننده بین آیتم‌های منو
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.grey.shade200,
        height: 1,
        thickness: 1,
      ),
    );
  }

  /// دیالوگ خروج از حساب
  void _showLogoutDialog(BuildContext context) {
    debugPrint('🚪 [ProfilePage] Show logout dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('خروج از حساب'),
          ],
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید از حساب کاربری خود خارج شوید؟',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('❌ [ProfilePage] Logout cancelled');
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'انصراف',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('✅ [ProfilePage] Logout confirmed');
              Navigator.pop(dialogContext);
              // ارسال رویداد خروج به AuthBloc (با استفاده از _authBloc)
              _authBloc.add(AuthLogout());
              // همچنین می‌توان رویداد خروج را به ProfileBloc هم ارسال کرد
              _profileBloc.add(ProfileLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}