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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentBannerPage = 0; // ✅ برای اندیکاتور بنرها
  final PageController _bannerPageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    _bannerPageController.dispose();
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
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (storeType != StoreType.supermarket && state.cuisines.isNotEmpty)
                    _buildHorizontalCuisines(blocContext, state.cuisines, primaryColor, currentLat, currentLng),
                  if (storeType != StoreType.supermarket) const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (storeType != StoreType.supermarket && state.banners.isNotEmpty)
                    _buildBanners(state.banners, currentLat, currentLng),
                  if (state.promoItems.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'تخفیف‌های ویژه', primaryColor),
                    _buildHorizontalPromos(state.promoItems, storeType),
                  ],
                  if (state.favoriteMerchants.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'فروشگاه‌های مورد علاقه', primaryColor),
                    _buildHorizontalMerchants(state.favoriteMerchants, storeType),
                  ],
                  if (storeType != StoreType.supermarket && state.specialOffers.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'پیشنهادهای ویژه', primaryColor),
                    _buildHorizontalMerchants(state.specialOffers, storeType),
                  ],
                  if (storeType != StoreType.supermarket && state.featuredMerchants.isNotEmpty) ...[
                    _buildSectionTitle(blocContext, 'فروشگاه‌های برگزیده', primaryColor),
                    _buildHorizontalMerchants(state.featuredMerchants, storeType),
                  ],
                  if (state.nearbyMerchants.isNotEmpty) ...[
                    _buildSectionTitle(
                      blocContext,
                      storeType == StoreType.supermarket ? 'همه سوپرمارکت‌ها' : 'همه رستوران‌ها و فروشگاه‌ها',
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

  // ==================== هدر ====================
  Widget _buildSliverHeader(BuildContext context, Color primaryColor, String searchHint, double lat, double lng) {
    return SliverAppBar(
      backgroundColor: primaryColor,
      floating: true,
      pinned: true,
      elevation: 0,
      expandedHeight: 145,
      collapsedHeight: 75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
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
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ارسال به',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'موقعیت من ...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
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
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            if (cartState.cartCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryColor, width: 2),
                                  ),
                                  child: Text(
                                    '${cartState.cartCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _onSearchChanged(context, query, lat, lng),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: searchHint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: primaryColor,
                  size: 26,
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged(context, '', lat, lng);
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== عنوان بخش (بدون "مشاهده همه") ====================
  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    Color primaryColor, {
    VoidCallback? onSeeAllTap,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            // ✅ جایگزین "مشاهده همه" با یک دکمه ساده (فلش)
            if (onSeeAllTap != null)
              GestureDetector(
                onTap: onSeeAllTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'بیشتر',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== دسته‌بندی‌های افقی ====================
  Widget _buildHorizontalCuisines(
    BuildContext context,
    List<CuisineDto> cuisines,
    Color primaryColor,
    double lat,
    double lng,
  ) {
    final storeType = context.read<StoreProvider>().currentStore;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 115,
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
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: Image.network(
                          cuisine.image,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Icon(
                            Icons.fastfood,
                            color: Colors.grey.shade300,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 78,
                      child: Text(
                        cuisine.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // ==================== بنرها با اندیکاتور پویا ====================
  Widget _buildBanners(List<String> banners, double lat, double lng) {
    final storeType = context.read<StoreProvider>().currentStore;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _bannerPageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerPage = index; // ✅ به‌روزرسانی صفحه فعلی
                    });
                  },
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            bannerUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // ✅ اندیکاتور پویا با تعداد دایره‌های برابر با تعداد بنرها
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentBannerPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentBannerPage == index
                              ? storeType.primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== تخفیف‌های افقی ====================
  Widget _buildHorizontalPromos(List<PromoItemDto> items, StoreType storeType) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) => PromoItemCard(
            item: items[index],
            storeType: storeType,
          ),
        ),
      ),
    );
  }

  // ==================== فروشگاه‌های افقی ====================
  Widget _buildHorizontalMerchants(List<MerchantDto> merchants, StoreType storeType) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: merchants.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: MerchantCard(
              merchant: merchants[index],
              isHorizontal: true,
              storeType: storeType,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== فروشگاه‌های عمودی ====================
  Widget _buildVerticalMerchants(List<MerchantDto> merchants, StoreType storeType) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: MerchantCard(
            merchant: merchants[index],
            isHorizontal: false,
            storeType: storeType,
          ),
        ),
        childCount: merchants.length,
      ),
    );
  }

  // ==================== نتایج جستجو ====================
  Widget _buildSearchResults(
    BuildContext context,
    List<SearchItemDto> items,
    String query,
    Color primaryColor,
    String searchHint,
    StoreType storeType,
    double lat,
    double lng,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, lat, lng),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${items.length} نتیجه برای "$query"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => SearchItemCard(
              item: items[index],
              storeType: storeType,
            ),
            childCount: items.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ==================== صفحه خالی جستجو ====================
  Widget _buildEmptySearchResult(
    BuildContext context,
    String query,
    Color primaryColor,
    String searchHint,
    double lat,
    double lng,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, lat, lng),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'نتیجه‌ای برای "$query" یافت نشد',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'عبارت دیگری جستجو کنید',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== خطای جستجو ====================
  Widget _buildSearchError(
    BuildContext context,
    String error,
    Color primaryColor,
    String searchHint,
    double lat,
    double lng,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, lat, lng),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'خطا در جستجو',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== لودینگ جستجو ====================
  Widget _buildSearchLoading(Color primaryColor, String searchHint, BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, primaryColor, searchHint, 0, 0),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== شیمر لودینگ ====================
  Widget _buildShimmerLoading(Color primaryColor) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: primaryColor,
            expandedHeight: 145,
            collapsedHeight: 75,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
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
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 250,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ==================== صفحه خطا ====================
  Widget _buildErrorState(BuildContext context, String error, Color color, StoreType storeType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'اتصال اینترنت را بررسی کنید',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                final currentStoreType = context.read<StoreProvider>().currentStore;
                context.read<HomeBloc>().add(HomeRefreshed(cuisineId: currentStoreType.cuisineId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: const Text(
                'تلاش مجدد',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}