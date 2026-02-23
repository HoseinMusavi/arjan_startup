import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/home/presentation/bloc/home_bloc.dart';
import 'package:arjan_startup/features/home/data/models/cuisine_dto.dart';
import 'package:arjan_startup/features/home/data/models/merchant_dto.dart';
import 'package:arjan_startup/features/home/presentation/widgets/merchant_card.dart';

// ✅ اضافه شدن CartBloc برای بررسی موجودی سبد خرید
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);
    const Color bgColor = Color(0xFFF8F9FA); 

    // ✅ استفاده از MultiBlocProvider تا بتوانیم وضعیت سبد خرید را در هدر چک کنیم
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<HomeBloc>()..add(HomeStarted())),
        BlocProvider.value(value: getIt<CartBloc>()), // وصل شدن به سبد خرید گلوبال
      ],
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
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeRefreshed());
                // می‌توانید سبد خرید را هم با رفرش صفحه چک کنید
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _buildAnimatedSliverHeader(primaryColor),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  
                  if (state.cuisines.isNotEmpty) 
                    _buildHorizontalCuisines(context, state.cuisines, primaryColor),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  if (state.banners.isNotEmpty) 
                    _buildBanners(state.banners),

                  if (state.specialOffers.isNotEmpty) ...[
                    _buildSectionTitle('پیشنهادهای ویژه آرژان', true, primaryColor),
                    _buildHorizontalMerchants(state.specialOffers),
                  ],

                  if (state.featuredMerchants.isNotEmpty) ...[
                    _buildSectionTitle('فروشگاه‌های برگزیده', true, primaryColor),
                    _buildHorizontalMerchants(state.featuredMerchants),
                  ],

                  if (state.nearbyMerchants.isNotEmpty) ...[
                    _buildSectionTitle('همه رستوران‌ها و فروشگاه‌ها', false, primaryColor),
                    _buildVerticalMerchants(state.nearbyMerchants),
                  ],
                  
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
  // 🎨 بخش هدر حرفه‌ای همراه با آیکون سبد خرید
  // ==========================================
  Widget _buildAnimatedSliverHeader(Color primaryColor) {
    return SliverAppBar(
      backgroundColor: primaryColor,
      floating: true,
      pinned: true, 
      elevation: 4,
      shadowColor: primaryColor.withValues(alpha: 0.5),
      expandedHeight: 130, 
      collapsedHeight: 70, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [primaryColor, const Color(0xFFFF9500)]),
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
                  // ✅ آیکون سبد خرید همراه با Badge
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      return IconButton(
                        splashRadius: 24,
                        onPressed: () {
                          // TODO: انتقال به صفحه سبد خرید
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                            if (cartState.cartCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryColor, width: 1.5),
                                  ),
                                  child: Text(
                                    '${cartState.cartCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
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
  // بقیه متدها بدون تغییر هستند
  // ==========================================
  Widget _buildHorizontalCuisines(BuildContext context, List<CuisineDto> cuisines, Color primaryColor) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 105,
        child: ListView.builder(
          scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: cuisines.length,
          itemBuilder: (context, index) {
            final cuisine = cuisines[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 65, width: 65, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))]), padding: const EdgeInsets.all(2), child: ClipOval(child: Image.network(cuisine.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Colors.grey.shade300, size: 30)))),
                      const SizedBox(height: 8),
                      SizedBox(width: 75, child: Text(cuisine.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black87), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
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

  Widget _buildBanners(List<String> banners) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          physics: const BouncingScrollPhysics(), controller: PageController(viewportFraction: 0.90), itemCount: banners.length,
          itemBuilder: (context, index) {
            if (banners[index].isEmpty) return const SizedBox();
            return Container(margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(banners[index], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey)))));
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool showSeeAll, Color primaryColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
            if (showSeeAll) Row(children: [Text('مشاهده همه', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Icon(Icons.arrow_forward_ios, size: 12, color: primaryColor)]),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMerchants(List<MerchantDto> merchants) {
    return SliverToBoxAdapter(
      child: SizedBox(height: 270, child: ListView.builder(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: merchants.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4), child: MerchantCard(merchant: merchants[index], isHorizontal: true)))),
    );
  }

  Widget _buildVerticalMerchants(List<MerchantDto> merchants) {
    return SliverList(delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: MerchantCard(merchant: merchants[index], isHorizontal: false)), childCount: merchants.length));
  }

  Widget _buildShimmerLoading(Color primaryColor) {
    return Shimmer.fromColors(baseColor: Colors.grey.shade200, highlightColor: Colors.grey.shade50, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 130, color: Colors.white), const SizedBox(height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (index) => const CircleAvatar(radius: 35, backgroundColor: Colors.white))), const SizedBox(height: 32), Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 20, width: 150, color: Colors.white), const SizedBox(height: 16), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(right: 16), height: 200, width: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))))))]));
  }

  Widget _buildErrorState(BuildContext context, String error, Color color) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey.shade300), const SizedBox(height: 16), Text(error, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)), const SizedBox(height: 24), ElevatedButton(onPressed: () => context.read<HomeBloc>().add(HomeRefreshed()), style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)), child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]));
  }
}