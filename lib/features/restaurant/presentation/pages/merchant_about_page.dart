import 'package:arjan_startup/features/restaurant/data/models/merchant_about_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/restaurant/presentation/bloc/about/merchant_about_bloc.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';

class MerchantAboutPage extends StatefulWidget {
  final String merchantId;
  final double lat;
  final double lng;

  const MerchantAboutPage({
    super.key,
    required this.merchantId,
    required this.lat,
    required this.lng,
  });

  @override
  State<MerchantAboutPage> createState() => _MerchantAboutPageState();
}

class _MerchantAboutPageState extends State<MerchantAboutPage> {
  late MerchantAboutBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MerchantAboutBloc(getIt<RestaurantRepository>())
      ..add(LoadMerchantAbout(
        merchantId: widget.merchantId,
        lat: widget.lat,
        lng: widget.lng,
      ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'اطلاعات رستوران',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocBuilder<MerchantAboutBloc, MerchantAboutState>(
          builder: (context, state) {
            if (state.status == MerchantAboutStatus.loading) {
              return _buildSkeletonLoading();
            }
            if (state.status == MerchantAboutStatus.failure) {
              return _buildErrorState(state.errorMessage);
            }
            if (state.status == MerchantAboutStatus.success && state.about != null) {
              return _buildAboutContent(state.about!);
            }
            return const Center(child: Text('اطلاعاتی موجود نیست'));
          },
        ),
      ),
    );
  }

  // ==================== اسکلتون لودینگ ====================
  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نام رستوران
            Container(
              height: 32,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            // ردیف امتیاز
            Row(
              children: [
                Container(
                  height: 20,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // کارت اطلاعات
            ...List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // عنوان ساعات کاری
            Container(
              height: 24,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            // کارت ساعات کاری
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            // عنوان روش‌های پرداخت
            Container(
              height: 24,
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(
                3,
                (index) => Container(
                  height: 36,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== صفحه خطا ====================
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری اطلاعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _bloc.add(LoadMerchantAbout(
                merchantId: widget.merchantId,
                lat: widget.lat,
                lng: widget.lng,
              ));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== محتوای اصلی ====================
  Widget _buildAboutContent(MerchantAboutDto about) {
    final data = about.data;
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // هدر رستوران
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withValues(alpha: 0.15),
                  primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.restaurantName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange.shade400, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      data.rating.ratings > 0
                          ? data.rating.ratings.toString()
                          : 'جدید',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      data.cuisine,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      data.reviewCount,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // کارت اطلاعات
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoItem(
                    Icons.location_on,
                    'آدرس',
                    data.completeAddress,
                    Colors.blue,
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    Icons.phone,
                    'تلفن رستوران',
                    data.restaurantPhone,
                    Colors.green,
                  ),
                  if (data.contactPhone.isNotEmpty) ...[
                    _buildDivider(),
                    _buildInfoItem(
                      Icons.phone_android,
                      'تماس',
                      data.contactPhone,
                      Colors.orange,
                    ),
                  ],
                  if (data.information.isNotEmpty) ...[
                    _buildDivider(),
                    _buildInfoItem(
                      Icons.info_outline,
                      'اطلاعات',
                      data.information,
                      Colors.purple,
                    ),
                  ],
                  if (data.website.isNotEmpty) ...[
                    _buildDivider(),
                    _buildInfoItem(
                      Icons.language,
                      'وب‌سایت',
                      data.website,
                      Colors.teal,
                    ),
                  ],
                  _buildDivider(),
                  _buildInfoItem(
                    Icons.local_offer,
                    'خدمات',
                    data.services,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ساعات کاری
          if (data.opening.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'ساعات کاری',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...data.opening.map((item) {
                      final bool isToday = item.day == _getTodayPersian();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.day,
                              style: TextStyle(
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.w500,
                                color: isToday ? primaryColor : Colors.black87,
                                fontSize: isToday ? 15 : 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? primaryColor.withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.hours.replaceAll('&nbsp;', ' '),
                                style: TextStyle(
                                  color: isToday
                                      ? primaryColor
                                      : Colors.grey.shade700,
                                  fontSize: 13,
                                  fontWeight:
                                      isToday ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // روش‌های پرداخت
          if (data.payment.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'روش‌های پرداخت',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.payment.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==================== ویجت‌های کمکی ====================
  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey.shade200,
        height: 1,
      ),
    );
  }

  // ==================== متدهای کمکی ====================
  String _getTodayPersian() {
    const weekDays = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
    final now = DateTime.now();
    // محاسبه روز هفته: شنبه = 0
    int weekday = now.weekday; // 1=Monday, 7=Sunday
    int persianWeekday = (weekday + 1) % 7; // تبدیل به شنبه=0
    return weekDays[persianWeekday];
  }
}