import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/auth/presentation/bloc/auth_bloc.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final ProfileBloc _profileBloc;
  late final AuthBloc _authBloc;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>();
    _authBloc = getIt<AuthBloc>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _profileBloc.add(const ProfileRequested());
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _authBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/login');
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                // ✅ Loading حرفه‌ای
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFFF7A00),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'در حال دریافت اطلاعات...',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is ProfileError) {
                return _buildErrorState(context, state.message);
              }
              if (state is ProfileLoaded) {
                return _buildProfileContent(context, state.profile);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'خطا در بارگذاری',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _profileBloc.add(const ProfileRequested()),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'تلاش مجدد',
                style: TextStyle(fontFamily: 'Vazir', fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ متد جدید برای ساخت نشان‌های هدر
  Widget _buildBadge(
    IconData icon,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Vazir',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, dynamic profile) {
    final avatar = profile.avatar ?? '';
    final firstName = profile.firstName ?? '';
    final lastName = profile.lastName ?? '';
    final fullName = profile.fullName ?? '$firstName $lastName';
    final contactPhone = profile.contactPhone ?? '';
    final emailAddress = profile.emailAddress ?? '';
    final hasAvatar = avatar.isNotEmpty;

    final menuItems = [
      _MenuItem(
        icon: Icons.edit_outlined,
        color: Colors.blue.shade600,
        title: 'ویرایش اطلاعات',
        subtitle: 'نام، شماره، ایمیل',
        route: '/profile/edit',
      ),
      _MenuItem(
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green.shade600,
        title: 'کیف پول',
        subtitle: 'موجودی و تراکنش‌ها',
        route: '/profile/points',
      ),
      _MenuItem(
        icon: Icons.location_on_outlined,
        color: Colors.purple.shade600,
        title: 'آدرس‌های من',
        subtitle: 'مدیریت آدرس‌ها',
        route: '/profile/addresses',
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        color: const Color(0xFFFF7A00),
        title: 'اعلان‌ها',
        subtitle: 'پیام‌ها و اطلاعیه‌ها',
        route: '/profile/notifications',
      ),
      _MenuItem(
        icon: Icons.support_outlined,
        color: Colors.teal.shade600,
        title: 'پشتیبانی',
        subtitle: 'ارتباط با ما',
        route: null,
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        _profileBloc.add(const ProfileRequested());
      },
      color: const Color(0xFFFF7A00),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================== اسلیور اپ‌بار مدرن ====================
          SliverAppBar(
            expandedHeight: 260, // ✅ افزایش ارتفاع
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFFF7A00),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF7A00),
                      Color(0xFFFFA63D),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(.5),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white24,
                          backgroundImage:
                              hasAvatar ? NetworkImage(avatar) : null,
                          child: !hasAvatar
                              ? const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        fullName.isNotEmpty
                            ? fullName
                            : 'کاربر گرامی',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      if (contactPhone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            contactPhone,
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(
                            Icons.star_rounded,
                            '۰ امتیاز',
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            Icons.verified_user_outlined,
                            'عضو فعال',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==================== لیست منوها ====================
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) return _buildMenuSection(context, menuItems);
                  if (index == 1) return _buildLogoutSection(context);
                  return const SizedBox.shrink();
                },
                childCount: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<_MenuItem> items) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // ✅ گردی بیشتر
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24, // ✅ سایه بیشتر
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade100, // ✅ اضافه شدن border
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItemTile(context, item),
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ✅ متد جدید _buildMenuItemTile با طراحی مدرن
  Widget _buildMenuItemTile(
    BuildContext context,
    _MenuItem item,
  ) {
    return ListTile(
      minLeadingWidth: 20,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 6,
      ),
      onTap: () {
        if (item.route != null) {
          context.push(item.route!);
        } else {
          _showSupportDialog(context);
        }
      },
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: item.color.withOpacity(.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          item.icon,
          color: item.color,
        ),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontFamily: 'Vazir',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          item.subtitle,
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          size: 18,
        ),
      ),
    );
  }

  // ✅ کارت خروج با طراحی Premium
  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F7), // ✅ رنگ ویژه
        borderRadius: BorderRadius.circular(24), // ✅ گردی بیشتر
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFD9D3), // ✅ border ویژه
        ),
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(context),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: const Text(
          'خروج از حساب کاربری',
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        subtitle: const Text(
          'اطلاعات شما حفظ می‌شود',
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.red.shade300,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        dense: true,
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'پشتیبانی',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'شماره تماس:',
              style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              '۰۲۱-۱۲۳۴۵۶۷۸',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 16,
                color: Color(0xFFFF7A00),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ساعات پاسخگویی:',
              style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.w500),
            ),
            const Text(
              'شنبه تا چهارشنبه ۹ تا ۱۸',
              style: TextStyle(fontFamily: 'Vazir', fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'بستن',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Color(0xFFFF7A00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text(
              'خروج از حساب',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید خارج شوید؟',
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'انصراف',
              style: TextStyle(fontFamily: 'Vazir', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _authBloc.add(AuthLogout());
              _profileBloc.add(ProfileLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'خروج',
              style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? route;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.route,
  });
}