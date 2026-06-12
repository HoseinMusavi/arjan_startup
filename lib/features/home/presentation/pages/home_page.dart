import 'dart:async';
import 'package:arjan_startup/features/home/data/models/promo_item_dto.dart';
import 'package:arjan_startup/features/home/data/models/search_item_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:arjan_startup/core/providers/store_provider.dart';
import 'package:arjan_startup/features/home/presentation/bloc/home_bloc.dart';
import 'package:arjan_startup/features/home/data/models/cuisine_dto.dart';
import 'package:arjan_startup/features/home/data/models/merchant_dto.dart';
import 'package:arjan_startup/features/home/presentation/widgets/merchant_card.dart';
import 'package:arjan_startup/features/home/presentation/widgets/search_item_card.dart';
import 'package:arjan_startup/features/home/presentation/widgets/promo_item_card.dart';
import 'package:arjan_startup/features/home/presentation/pages/merchant_list_page.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/cart/presentation/pages/cart_page.dart';
import 'package:arjan_startup/features/home/domain/repositories/home_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String query, double lat, double lng) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      context.read<HomeBloc>().add(const HomeSearchCleared());
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<HomeBloc>().add(HomeSearchSubmitted(query: query, lat: lat, lng: lng));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeType = context.watch<StoreProvider>().currentStore;
    final primaryColor = storeType.primaryColor;
    final cuisineId = storeType.cuisineId;
    final bgColor = const Color(0xFFF8F9FA);
    final searchHint = storeType == StoreType.supermarket ? 'جستجو در سوپرمارکت...' : 'جستجو در ارجان فود...';
    const currentLat = 30.5882768;
    const currentLng = 50.2575974;

    return BlocProvider(
      create: (context) {
        getIt<CartBloc>().add(const LoadFirstCart(30.5882768, 50.2575974));
        return getIt<HomeBloc>()..add(HomeStarted(cuisineId: cuisineId));
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (blocContext, state) {
            if (state.searchStatus == SearchStatus.loading) {
              return _buildSearchLoading(primaryColor, searchHint, blocContext);
            }
            if (state.searchStatus == SearchStatus.success && state.searchResults.isNotEmpty) {
              return _buildSearchResults(blocContext, state.searchResults, state.searchQuery,
                  primaryColor, searchHint, storeType, currentLat, currentLng);
            }
            if (state.searchStatus == SearchStatus.empty) {
              return _buildEmptySearchResult(blocContext, state.searchQuery, primaryColor, searchHint, currentLat, currentLng);
            }
            if (state.searchStatus == SearchStatus.failure) {
              return _buildSearchError(blocContext, state.searchErrorMessage, primaryColor, searchHint, currentLat, currentLng);
            }
            if (state.status == HomeStatus.initial || state.status == HomeStatus.loading) {
              return _buildShimmerLoading(primaryColor);
            }
            if (state.status == HomeStatus.failure) {
              return _buildErrorState(blocContext, state.errorMessage, primaryColor, storeType);
            }
            return RefreshIndicator(
              color: primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                blocContext.read<HomeBloc>().add(HomeRefreshed(cuisineId: cuisineId));
                getIt<CartBloc>().add(const LoadFirstCart(30.5882768, 50.2575974));
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _buildSliverHeader(blocContext, primaryColor, searchHint, currentLat, currentLng),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (storeType != StoreType.supermarket && state.cuisines.isNotEmpty)
                    _buildHorizontalCuisines(blocContext, state.cuisines, primaryColor, currentLat, currentLng),
                  if (storeType != StoreType.supermarket) const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (storeType != StoreType.supermarket && state.banners.isNotEmpty)
                    _buildBanners(state.banners, currentLat, currentLng),
                  if (state.promoItems.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'تخفیف‌های ویژه', true, primaryColor),
                    _buildHorizontalPromos(state.promoItems, storeType),
                  ],
                  if (state.favoriteMerchants.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'فروشگاه‌های مورد علاقه', true, primaryColor),
                    _buildHorizontalMerchants(state.favoriteMerchants, storeType),
                  ],
                  if (storeType != StoreType.supermarket && state.specialOffers.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'پیشنهادهای ویژه', true, primaryColor),
                    _buildHorizontalMerchants(state.specialOffers, storeType),
                  ],
                  if (storeType != StoreType.supermarket && state.featuredMerchants.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'فروشگاه‌های برگزیده', true, primaryColor),
                    _buildHorizontalMerchants(state.featuredMerchants, storeType),
                  ],
                  if (state.nearbyMerchants.isNotEmpty) ...[
                    _buildSectionTitle(
                      blocContext,
                      storeType == StoreType.supermarket ? 'همه سوپرمارکت‌ها' : 'همه رستوران‌ها و فروشگاه‌ها',
                      true,
                      primaryColor,
                      onSeeAllTap: () {
                        Navigator.push(
                          blocContext,
                          MaterialPageRoute(
                            builder: (context) => MerchantListPage(
                              fetchMerchants: () async {
                                final result = await getIt<HomeRepository>().getMerchants('byLatLong', currentLat, currentLng);
                                return result.fold((failure) => <MerchantDto>[], (merchants) => merchants);
                              },
                              title: storeType == StoreType.supermarket ? 'همه سوپرمارکت‌ها' : 'همه رستوران‌ها و فروشگاه‌ها',
                              storeType: storeType,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildVerticalMerchants(state.nearbyMerchants, storeType),
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

  // ---------- هدر اصلی (بدون تغییر - مثل نسخه قبلی) ----------
  Widget _buildSliverHeader(BuildContext context, Color primaryColor, String searchHint, double lat, double lng) {
    return SliverAppBar(
      backgroundColor: primaryColor,
      floating: true,
      pinned: true,
      elevation: 4,
      shadowColor: primaryColor.withValues(alpha: 0.5),
      expandedHeight: 130,
      collapsedHeight: 70,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [primaryColor, primaryColor.withValues(alpha: 0.8)]),
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
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Colors.white, size: 20)),
                      const SizedBox(width: 10),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Text('ارسال به', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Row(children: [Text('موقعیت من ...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)), Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.white)]),
                      ]),
                    ],
                  ),
                  BlocBuilder<CartBloc, CartState>(
                    bloc: getIt<CartBloc>(),
                    builder: (cartContext, cartState) {
                      return IconButton(
                        splashRadius: 24,
                        onPressed: () => Navigator.push(cartContext, MaterialPageRoute(builder: (_) => const CartPage())),
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
                                  decoration: BoxDecoration(color: Colors.red.shade600, shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 1.5)),
                                  child: Text('${cartState.cartCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _onSearchChanged(context, query, lat, lng),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: searchHint,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 24),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged(context, '', lat, lng);
                  },
                  child: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- عنوان بخش با دکمه مشاهده همه (مثل قبل) ----------
  Widget _buildSectionTitle(BuildContext context, String title, bool showSeeAll, Color primaryColor, {VoidCallback? onSeeAllTap}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
            if (showSeeAll)
              GestureDetector(
                onTap: onSeeAllTap,
                child: Row(
                  children: [
                    Text('مشاهده همه', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: primaryColor),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- نتایج جستجو ----------
  Widget _buildSearchResults(BuildContext context, List<SearchItemDto> items, String query, Color primaryColor, String searchHint, StoreType storeType, double lat, double lng) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, lat, lng),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('${items.length} نتیجه برای "$query"', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => SearchItemCard(item: items[index], storeType: storeType),
            childCount: items.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildEmptySearchResult(BuildContext context, String query, Color primaryColor, String searchHint, double lat, double lng) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, lat, lng),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('نتیجه‌ای برای "$query" یافت نشد', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('عبارت دیگری جستجو کنید', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchError(BuildContext context, String error, Color primaryColor, String searchHint, double lat, double lng) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, lat, lng),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 70, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('خطا در جستجو', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Text(error, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchLoading(Color primaryColor, String searchHint, BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, 0, 0),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- دسته‌بندی‌های افقی ----------
  Widget _buildHorizontalCuisines(BuildContext context, List<CuisineDto> cuisines, Color primaryColor, double lat, double lng) {
    final storeType = context.read<StoreProvider>().currentStore;
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MerchantListPage(
                        fetchMerchants: () async {
                          final result = await getIt<HomeRepository>().getMerchants('byCuisine', lat, lng, cuisineId: cuisine.id);
                          return result.fold((failure) => <MerchantDto>[], (merchants) => merchants);
                        },
                        title: cuisine.name,
                        storeType: storeType,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))]),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.network(cuisine.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Colors.grey.shade300, size: 30)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(width: 75, child: Text(cuisine.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black87), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- بنرها ----------
  Widget _buildBanners(List<String> banners, double lat, double lng) {
    final storeType = context.read<StoreProvider>().currentStore;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: PageController(viewportFraction: 0.90),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final bannerUrl = banners[index];
            if (bannerUrl.isEmpty) return const SizedBox();
            final bannerId = bannerUrl.split('/').last.split('.').first;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MerchantListPage(
                      fetchMerchants: () async {
                        final result = await getIt<HomeRepository>().getMerchantsByBanner(bannerId: bannerId, lat: lat, lng: lng);
                        return result.fold((failure) => <MerchantDto>[], (merchants) => merchants);
                      },
                      title: 'فروشگاه‌های مرتبط',
                      storeType: storeType,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(bannerUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- تخفیف‌ها ----------
  Widget _buildHorizontalPromos(List<PromoItemDto> items, StoreType storeType) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) => PromoItemCard(item: items[index], storeType: storeType),
        ),
      ),
    );
  }

  // ---------- فروشگاه‌های افقی ----------
  Widget _buildHorizontalMerchants(List<MerchantDto> merchants, StoreType storeType) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: merchants.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: MerchantCard(merchant: merchants[index], isHorizontal: true, storeType: storeType),
          ),
        ),
      ),
    );
  }

  // ---------- فروشگاه‌های عمودی ----------
  Widget _buildVerticalMerchants(List<MerchantDto> merchants, StoreType storeType) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: MerchantCard(merchant: merchants[index], isHorizontal: false, storeType: storeType),
        ),
        childCount: merchants.length,
      ),
    );
  }

  // ---------- شیمر لودینگ (مثل قبل) ----------
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(right: 16), height: 200, width: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- صفحه خطا ----------
  Widget _buildErrorState(BuildContext context, String error, Color color, StoreType storeType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(error, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final currentStoreType = context.read<StoreProvider>().currentStore;
              context.read<HomeBloc>().add(HomeRefreshed(cuisineId: currentStoreType.cuisineId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}