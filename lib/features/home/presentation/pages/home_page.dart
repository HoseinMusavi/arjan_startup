import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/home_bloc.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';
import '../widgets/home_header.dart'; // ویجتی که خودتان ساختید
import '../widgets/merchant_card.dart'; // ویجتی که خودتان ساختید

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00); // نارنجی اصلی شبیه اسنپ

    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(HomeStarted()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              
              if (state.status == HomeStatus.loading || state.status == HomeStatus.initial) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }

              if (state.status == HomeStatus.failure) {
                return _buildErrorState(context, state.errorMessage, primaryColor);
              }

              return RefreshIndicator(
                color: primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<HomeBloc>().add(HomeRefreshed());
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: HomeHeader()), // هدر اختصاصی
                    
                    if (state.banners.isNotEmpty) 
                      _buildBanners(state.banners),
                    
                    if (state.cuisines.isNotEmpty) 
                      _buildCuisinesGrid(state.cuisines),
                    
                    // خط جداکننده نرم
                    SliverToBoxAdapter(
                      child: Container(
                        height: 8,
                        color: Colors.grey.shade100,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    if (state.specialOffers.isNotEmpty) ...[
                      _buildSectionTitle('پیشنهادهای ویژه آرژان', true, primaryColor),
                      _buildHorizontalMerchants(state.specialOffers),
                    ],

                    if (state.featuredMerchants.isNotEmpty) ...[
                      _buildSectionTitle('برگزیده‌ها', true, primaryColor),
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
      ),
    );
  }

  // --- ویجت‌های کمکی صفحه ---

  Widget _buildErrorState(BuildContext context, String error, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(error, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HomeBloc>().add(HomeRefreshed()),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildBanners(List<String> banners) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        height: 180,
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: PageController(viewportFraction: 0.90),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
                image: DecorationImage(
                  image: NetworkImage(banners[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCuisinesGrid(List<CuisineDto> cuisines) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, 
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75, // تناسب ارتفاع برای جا شدن عکس و متن
          ),
          itemCount: cuisines.length > 8 ? 8 : cuisines.length, 
          itemBuilder: (context, index) {
            final cuisine = cuisines[index];
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24), // گوشه‌های گرد تر برای دسته‌بندی‌ها
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                      image: DecorationImage(
                        image: NetworkImage(cuisine.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  cuisine.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
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

  Widget _buildSectionTitle(String title, bool showSeeAll, Color primaryColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
        height: 275, // ارتفاع کافی برای کارت عمودی
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: merchants.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: MerchantCard(merchant: merchants[index], isHorizontal: true),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerticalMerchants(List<MerchantDto> merchants) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: MerchantCard(merchant: merchants[index], isHorizontal: false),
          );
        },
        childCount: merchants.length,
      ),
    );
  }
}