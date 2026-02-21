import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/home_bloc.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // رنگ سازمانی اپلیکیشن (نارنجی پررنگ و جذاب)
    const Color primaryColor = Color(0xFFFF7A00);
    const Color bgColor = Color(0xFFF8F9FA); // طوسی بسیار روشن برای پس‌زمینه

    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(HomeStarted()),
      child: Scaffold(
        backgroundColor: bgColor,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.initial || state.status == HomeStatus.loading) {
              return _buildShimmerLoading(primaryColor);
            }

            if (state.status == HomeStatus.failure) {
              return _buildErrorState(context, state.errorMessage, primaryColor);
            }

            return RefreshIndicator(
              color: primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async => context.read<HomeBloc>().add(HomeRefreshed()),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // 1. هدر انیمیشنی و نارنجی رنگ
                  _buildAnimatedSliverHeader(primaryColor),
                  
                  // فاصله بالا
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 2. لیست افقی دسته‌بندی‌ها (اسکرول نرم)
                  if (state.cuisines.isNotEmpty) 
                    _buildHorizontalCuisines(state.cuisines),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 3. بنرهای تبلیغاتی با سایز ثابت و افکت ورق خوردن
                  if (state.banners.isNotEmpty) 
                    _buildBanners(state.banners),

                  // 4. پیشنهادهای ویژه (لیست افقی رستوران‌ها)
                  if (state.specialOffers.isNotEmpty) ...[
                    _buildSectionTitle('پیشنهادهای ویژه آرژان', true, primaryColor),
                    _buildHorizontalMerchants(state.specialOffers),
                  ],

                  // 5. برگزیده‌ها
                  if (state.featuredMerchants.isNotEmpty) ...[
                    _buildSectionTitle('فروشگاه‌های برگزیده', true, primaryColor),
                    _buildHorizontalMerchants(state.featuredMerchants),
                  ],

                  // 6. همه رستوران‌ها (لیست عمودی)
                  if (state.nearbyMerchants.isNotEmpty) ...[
                    _buildSectionTitle('همه رستوران‌ها و فروشگاه‌ها', false, primaryColor),
                    _buildVerticalMerchants(state.nearbyMerchants),
                  ],
                  
                  // فضای خالی برای باتم نویگیشن
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🎨 بخش اول: هدر حرفه‌ای و انیمیشنی (SliverAppBar)
  // ==========================================
  Widget _buildAnimatedSliverHeader(Color primaryColor) {
    return SliverAppBar(
      backgroundColor: primaryColor,
      floating: true,
      pinned: true, // نوار جستجو همیشه بالا می‌ماند
      elevation: 4,
      shadowColor: primaryColor.withValues(alpha: 0.5),
      expandedHeight: 130, // ارتفاع هدر باز شده
      collapsedHeight: 70, // ارتفاع هدر بسته شده
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [primaryColor, Color(0xFFFF9500)],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ارسال به', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Row(
                            children: [
                              Text('موقعیت من ...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                Text('جستجو در آرژان فود...', style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🎨 بخش دوم: لیست افقی دسته‌بندی‌ها (Cuisines)
  // ==========================================
  Widget _buildHorizontalCuisines(List<CuisineDto> cuisines) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 105,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: cuisines.length,
          itemBuilder: (context, index) {
            final cuisine = cuisines[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(2), // کادر سفید دور عکس
                    child: ClipOval(
                      child: Image.network(
                        cuisine.image,
                        fit: BoxFit.cover, // ✅ حل مشکل سایز عکس‌ها
                        errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Colors.grey.shade300, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 75,
                    child: Text(
                      cuisine.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black87),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🎨 بخش سوم: بنرها (حل مشکل ابعاد تصاویر)
  // ==========================================
  Widget _buildBanners(List<String> banners) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: PageController(viewportFraction: 0.90),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            if (banners[index].isEmpty) return const SizedBox();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  banners[index],
                  fit: BoxFit.cover, // ✅ تمام عکس‌ها دقیقا هم‌سایز کادر می‌شوند
                  errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🎨 بخش چهارم: کارت رستوران (کاور فیت شده + لوگوی گرد)
  // ==========================================
  Widget _buildMerchantCard(MerchantDto merchant, {required bool isHorizontal}) {
    return Container(
      width: isHorizontal ? 270 : double.infinity,
      margin: EdgeInsets.only(bottom: isHorizontal ? 0 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // کاور اصلی (با مدیریت دقیق سایز)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 2.2, // ✅ نسبت تصویر ثابت برای جلوگیری از به‌هم‌ریختگی
                  child: Image.network(
                    merchant.background.isNotEmpty ? merchant.background : merchant.logo,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey.shade100, child: const Icon(Icons.storefront, color: Colors.grey, size: 40)),
                  ),
                ),
              ),
              // سایه ملایم روی عکس
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)]),
                  ),
                ),
              ),
              // لوگوی گرد رستوران
              Positioned(
                bottom: -20,
                right: 16,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))]),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.network(merchant.logo, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, color: Colors.grey)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(merchant.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15), overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Text(merchant.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade700)),
                          const SizedBox(width: 4),
                          Icon(Icons.star_rounded, color: Colors.green.shade700, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(merchant.cuisineText.isNotEmpty ? merchant.cuisineText : 'فست فود • پیتزا', style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.motorcycle_outlined, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(merchant.deliveryFee == '0' || merchant.deliveryFee.isEmpty ? 'ارسال رایگان' : '${merchant.deliveryFee} تومان', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // متدهای کمکی و Shimmer Loading
  // ==========================================
  
  Widget _buildSectionTitle(String title, bool showSeeAll, Color primaryColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
            if (showSeeAll)
              Row(
                children: [
                  Text('مشاهده همه', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: primaryColor),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMerchants(List<MerchantDto> merchants) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: merchants.length,
          itemBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4), child: _buildMerchantCard(merchants[index], isHorizontal: true)),
        ),
      ),
    );
  }

  Widget _buildVerticalMerchants(List<MerchantDto> merchants) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: _buildMerchantCard(merchants[index], isHorizontal: false)),
        childCount: merchants.length,
      ),
    );
  }

  Widget _buildShimmerLoading(Color primaryColor) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 130, color: Colors.white), 
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (index) => const CircleAvatar(radius: 35, backgroundColor: Colors.white))),
          const SizedBox(height: 32),
          Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 20, width: 150, color: Colors.white),
          const SizedBox(height: 16),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(right: 16), height: 200, width: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))))))
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(error, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<HomeBloc>().add(HomeRefreshed()),
            style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}