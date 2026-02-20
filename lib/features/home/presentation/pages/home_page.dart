import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/home_bloc.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(HomeStarted()),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100, // پس‌زمینه روشن‌تر برای جداسازی بهتر کارت‌ها
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading || state.status == HomeStatus.initial) {
                return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)); // رنگ صورتی اسنپ‌فود
              }

              if (state.status == HomeStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => context.read<HomeBloc>().add(HomeRefreshed()),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                        child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.pinkAccent,
                onRefresh: () async {
                  context.read<HomeBloc>().add(HomeRefreshed());
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeader(),
                    if (state.banners.isNotEmpty) _buildBanners(state.banners),
                    if (state.cuisines.isNotEmpty) _buildCuisinesGrid(state.cuisines),
                    
                    // فاصله بعد از دسته‌بندی‌ها
                    const SliverToBoxAdapter(child: SizedBox(height: 16)), 

                    // بخش برگزیده‌ها یا پیشنهادهای ویژه (لیست افقی)
                    if (state.featuredMerchants.isNotEmpty) ...[
                      _buildSectionTitle('پیشنهادهای ویژه آرژان', true),
                      _buildHorizontalList(state.featuredMerchants),
                    ],

                    // بخش همه رستوران‌ها (لیست عمودی)
                    if (state.nearbyMerchants.isNotEmpty) ...[
                      _buildSectionTitle('همه رستوران‌ها و فروشگاه‌ها', false),
                      _buildVerticalList(state.nearbyMerchants),
                    ],
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 100)), // فضای خالی پایین برای نویگیشن بار
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- 1. هدر اصلی (شامل لوکیشن و سرچ بار) ---
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.grey.shade800, size: 20),
                    const SizedBox(width: 4),
                    const Text(
                      'موقعیت من',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade800, size: 20),
                  ],
                ),
                Icon(Icons.notifications_none_rounded, color: Colors.grey.shade800),
              ],
            ),
            const SizedBox(height: 16),
            // سرچ بار شبیه اسنپ فود
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'جستجو در آرژان فود...',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. بنرهای اسلایدی ---
  Widget _buildBanners(List<String> banners) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        height: 160,
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: PageController(viewportFraction: 0.92),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 8, left: 8, bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(banners[index]),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 3. گرید دسته‌بندی‌ها (دقیقاً مشابه اسنپ‌فود) ---
  Widget _buildCuisinesGrid(List<CuisineDto> cuisines) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 ستون در یک ردیف
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8, // تنظیم ارتفاع عکس به متن
          ),
          itemCount: cuisines.length > 8 ? 8 : cuisines.length, // نهایتا 8 تا نشون بده (دو ردیف)
          itemBuilder: (context, index) {
            final cuisine = cuisines[index];
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.15), 
                          blurRadius: 10, 
                          offset: const Offset(0, 4)
                        )
                      ],
                      image: DecorationImage(
                        image: NetworkImage(cuisine.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cuisine.name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- تایتل سکشن‌ها ---
  Widget _buildSectionTitle(String title, bool showSeeAll) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            if (showSeeAll)
              const Row(
                children: [
                  Text('مشاهده همه', style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.pinkAccent),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- 4. لیست افقی فروشگاه‌ها (برای پیشنهادهای ویژه) ---
  Widget _buildHorizontalList(List<MerchantDto> merchants) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: merchants.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
              child: _buildMerchantCard(merchants[index], isHorizontal: true),
            );
          },
        ),
      ),
    );
  }

  // --- 5. لیست عمودی فروشگاه‌ها ---
  Widget _buildVerticalList(List<MerchantDto> merchants) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildMerchantCard(merchants[index], isHorizontal: false),
          );
        },
        childCount: merchants.length,
      ),
    );
  }

  // --- طراحی کارت فروشگاه (دقیقاً مشابه اسنپ‌فود) ---
  Widget _buildMerchantCard(MerchantDto merchant, {required bool isHorizontal}) {
    return Container(
      width: isHorizontal ? 270 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کاور فروشگاه و لوگو
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(merchant.background.isNotEmpty ? merchant.background : merchant.logo),
                    fit: BoxFit.cover,
                  ),
                ),
                // لایه تاریک روی عکس برای دیده شدن بهتر
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                    ),
                  ),
                ),
              ),
              // لوگوی مربعی با سایه (اسنپ‌فودی)
              Positioned(
                bottom: -20,
                right: 16,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
                    ],
                    image: DecorationImage(
                      image: NetworkImage(merchant.logo),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28), // فاصله برای جبران لوگوی شناور
          
          // اطلاعات پایین کارت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        merchant.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // امتیاز فروشگاه
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(merchant.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade800)),
                          const SizedBox(width: 2),
                          Icon(Icons.star, color: Colors.green.shade800, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // نوع غذا
                Text(
                  merchant.cuisineText.isNotEmpty ? merchant.cuisineText : 'فست فود، پیتزا',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // هزینه ارسال
                Row(
                  children: [
                    Icon(Icons.motorcycle, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      merchant.deliveryFee == '0' || merchant.deliveryFee.isEmpty 
                          ? 'ارسال رایگان' 
                          : 'ارسال ${merchant.deliveryFee} تومان', 
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
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
}