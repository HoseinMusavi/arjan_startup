import 'dart:async';
import 'package:arjan_startup/features/cart/presentation/pages/cart_page.dart';
import 'package:arjan_startup/features/restaurant/presentation/bloc/restaurant/restaurant_bloc.dart';
import 'package:arjan_startup/features/restaurant/presentation/pages/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/search_category_item_dto.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/restaurant/presentation/pages/item_details_page.dart';
import 'package:arjan_startup/features/restaurant/presentation/pages/merchant_about_page.dart';
import 'package:arjan_startup/features/restaurant/presentation/pages/merchant_reviews_page.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';

class MerchantMenuPage extends StatelessWidget {
  final String merchantId;
  final String merchantName;
  final StoreType storeType;

  const MerchantMenuPage({
    super.key,
    required this.merchantId,
    required this.merchantName,
    this.storeType = StoreType.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🏪 [MERCHANT_PAGE] باز شدن صفحه فروشگاه: $merchantName (ID: $merchantId)');
    final Color primaryColor = storeType.primaryColor;

    return BlocProvider(
      create: (context) {
        debugPrint('🏪 [MERCHANT_PAGE] ایجاد RestaurantBloc برای فروشگاه: $merchantId');
        return RestaurantBloc(getIt<RestaurantRepository>())
          ..add(RestaurantStarted(merchantId, 30.5882768, 50.2575974));
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: MultiBlocListener(
          listeners: [
            BlocListener<CartBloc, CartState>(
              bloc: getIt<CartBloc>(),
              listenWhen: (previous, current) => current.status == CartStatus.conflict,
              listener: (context, state) {
                debugPrint('⚠️ [MERCHANT_PAGE] تداخل سبد خرید شناسایی شد');
                _showConflictDialog(context, state, primaryColor);
              },
            ),
            BlocListener<CartBloc, CartState>(
              bloc: getIt<CartBloc>(),
              listenWhen: (previous, current) =>
                  current.status == CartStatus.failure && current.errorMessage.isNotEmpty,
              listener: (context, state) {
                debugPrint('❌ [MERCHANT_PAGE] خطا از سبد خرید: ${state.errorMessage}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
          child: BlocBuilder<RestaurantBloc, RestaurantState>(
            builder: (context, state) {
              debugPrint('🔄 [MERCHANT_PAGE] وضعیت: status=${state.status}, menuStatus=${state.menuStatus}, items=${state.items.length}');

              // ✅ وضعیت جستجو
              if (state.searchMenuStatus == SearchMenuStatus.loading) {
                debugPrint('🔍 [MERCHANT_PAGE] در حال جستجو...');
                return const Center(child: CircularProgressIndicator());
              }
              if (state.searchMenuStatus == SearchMenuStatus.success && state.searchResults.isNotEmpty) {
                debugPrint('🔍 [MERCHANT_PAGE] ${state.searchResults.length} نتیجه جستجو یافت شد');
                return _buildSearchResults(
                  context,
                  state.searchResults,
                  primaryColor,
                );
              }
              if (state.searchMenuStatus == SearchMenuStatus.empty) {
                debugPrint('🔍 [MERCHANT_PAGE] نتیجه‌ای یافت نشد برای: ${state.searchQuery}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'نتیجه‌ای برای "${state.searchQuery}" یافت نشد',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }
              if (state.searchMenuStatus == SearchMenuStatus.failure) {
                debugPrint('❌ [MERCHANT_PAGE] خطا در جستجو: ${state.errorMessage}');
                return Center(child: Text('خطا در جستجو: ${state.errorMessage}'));
              }

              // ✅ وضعیت اصلی
              if (state.status == RestaurantStatus.initial || state.status == RestaurantStatus.loading) {
                debugPrint('⏳ [MERCHANT_PAGE] در حال بارگذاری اطلاعات فروشگاه...');
                return _buildShimmerLoading(primaryColor);
              }
              if (state.status == RestaurantStatus.failure) {
                debugPrint('❌ [MERCHANT_PAGE] خطا در بارگذاری: ${state.errorMessage}');
                return Center(child: Text(state.errorMessage));
              }
              final info = state.info;
              if (info == null) {
                debugPrint('⚠️ [MERCHANT_PAGE] اطلاعات فروشگاه null است');
                return const Center(child: Text('اطلاعات یافت نشد'));
              }

              debugPrint('✅ [MERCHANT_PAGE] بارگذاری کامل شد، ${state.categories.length} دسته و ${state.items.length} آیتم');

              return CustomScrollView(
                slivers: [
                  // ✅ هدر پیشرفته
                  _buildAdvancedHeader(context, info, primaryColor, state),

                  // ✅ نوار جستجو (با کنترلر داخلی)
                  SliverToBoxAdapter(
                    child: _buildSearchBar(primaryColor, context),
                  ),

                  // ✅ دسته‌بندی‌ها
                  if (storeType != StoreType.supermarket && state.categories.isNotEmpty)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryTabDelegate(
                        child: _buildCategoryTabs(state, primaryColor, context),
                      ),
                    ),

                  // ✅ آیتم‌های منو
                  if (state.menuStatus == MenuLoadingStatus.loading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  else if (state.items.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('آیتمی در این دسته وجود ندارد'),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMenuItem(
                          state.items[index],
                          state.selectedCategoryId,
                          primaryColor,
                          merchantId,
                          30.5882768,
                          50.2575974,
                          merchantName,
                          storeType,
                          context,
                        ),
                        childCount: state.items.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
          bloc: getIt<CartBloc>(),
          builder: (context, cartState) {
            if (cartState.cartCount > 0) {
              debugPrint('🛒 [MERCHANT_PAGE] نمایش نوار پایین سبد خرید: ${cartState.cartCount} آیتم');
              return _buildFloatingCartBar(context, cartState, primaryColor);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ==================== هدر پیشرفته ====================
  Widget _buildAdvancedHeader(
    BuildContext context,
    RestaurantInfoDto info,
    Color primaryColor,
    RestaurantState state,
  ) {
    debugPrint('📋 [HEADER] ساخت هدر برای: ${info.name}');
    final isOpen = info.status == 'باز است' || info.status == 'open' || info.status == 'Open';
    final statusColor = isOpen ? Colors.green : Colors.red;
    final statusText = isOpen ? 'باز است' : 'بسته';
    final ratingText = info.rating > 0 ? info.rating.toStringAsFixed(1) : 'جدید';

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      floating: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        onPressed: () {
          debugPrint('🔙 [HEADER] بازگشت به صفحه قبلی');
          Navigator.pop(context);
        },
      ),
      actions: [
        // دکمه اشتراک‌گذاری
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () {
            debugPrint('📤 [HEADER] اشتراک‌گذاری فروشگاه: ${info.name}');
            _shareMerchant(info);
          },
        ),
        // دکمه علاقه‌مندی
        FavoriteButton(
          merchantId: merchantId,
          lat: 30.5882768,
          lng: 50.2575974,
        ),
        // دکمه نظرات
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.reviews_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () {
            debugPrint('⭐ [HEADER] رفتن به صفحه نظرات');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MerchantReviewsPage(
                  merchantId: merchantId,
                  lat: 30.5882768,
                  lng: 50.2575974,
                ),
              ),
            );
          },
        ),
        // دکمه اطلاعات فروشگاه
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              debugPrint('ℹ️ [HEADER] رفتن به صفحه اطلاعات فروشگاه');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MerchantAboutPage(
                    merchantId: merchantId,
                    lat: 30.5882768,
                    lng: 50.2575974,
                  ),
                ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outlined, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'اطلاعات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // عکس پس‌زمینه
            Image.network(
              info.backgroundUrl.isNotEmpty ? info.backgroundUrl : info.logo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('⚠️ [HEADER] خطا در بارگذاری عکس پس‌زمینه: $error');
                return Container(
                  color: primaryColor,
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            ),
            // گرادیانت تیره
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // محتوای هدر
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نام رستوران
                  Text(
                    info.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // ردیف اطلاعات
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      // امتیاز
                      _buildHeaderChip(
                        icon: Icons.star_rounded,
                        text: ratingText,
                        color: Colors.amber,
                      ),
                      // وضعیت
                      _buildHeaderChip(
                        icon: isOpen ? Icons.check_circle : Icons.cancel,
                        text: statusText,
                        color: statusColor,
                      ),
                      // نوع خدمات
                      _buildHeaderChip(
                        icon: Icons.motorcycle_outlined,
                        text: 'تحویل درب منزل',
                        color: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ویجت Chip هدر ====================
  Widget _buildHeaderChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== نوار جستجو (اصلاح شده با debounce) ====================
  Widget _buildSearchBar(
    Color primaryColor,
    BuildContext context,
  ) {
    debugPrint('🔍 [SEARCH] ساخت نوار جستجو');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _SearchTextField(
          storeType: storeType,
          onSearch: (query) {
            debugPrint('🔍 [SEARCH] متن جستجو تغییر کرد: "$query"');
            if (query.trim().isEmpty) {
              context.read<RestaurantBloc>().add(const ClearSearch());
              return;
            }
            context.read<RestaurantBloc>().add(SearchMenu(query));
          },
        ),
      ),
    );
  }

  // ==================== دسته‌بندی‌ها ====================
  Widget _buildCategoryTabs(
    RestaurantState state,
    Color primaryColor,
    BuildContext context,
  ) {
    debugPrint('📑 [CATEGORY] ساخت ${state.categories.length} دسته‌بندی');
    return Container(
      color: Colors.white,
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final isSelected = state.selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                debugPrint('📑 [CATEGORY] تغییر دسته به: ${category.name} (ID: ${category.id})');
                context.read<RestaurantBloc>().add(CategoryChanged(category.id));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.check_circle, size: 14, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== اشتراک‌گذاری ====================
  void _shareMerchant(RestaurantInfoDto info) {
    debugPrint('📤 [SHARE] اشتراک‌گذاری فروشگاه: ${info.name}');
    final String shareText =
        '🍽️ ${info.name}\n'
        '📍 ${info.address}\n'
        '⭐ ${info.rating > 0 ? info.rating.toStringAsFixed(1) : 'جدید'}\n'
        '📱 از طریق ارجان اپ سفارش دهید!';
    
    SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: info.name,
      ),
    );
    debugPrint('✅ [SHARE] اشتراک‌گذاری انجام شد');
  }

  // ==================== دیالوگ تداخل سبد خرید ====================
  void _showConflictDialog(BuildContext context, CartState state, Color primaryColor) {
    debugPrint('⚠️ [CONFLICT] نمایش دیالوگ تداخل سبد خرید');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'سبد خرید فعال است!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'شما محصولاتی از یک فروشگاه دیگر در سبد خرید دارید. برای خرید از این فروشگاه، سبد قبلی حذف خواهد شد. موافقید؟',
          style: TextStyle(height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('❌ [CONFLICT] کاربر انصراف داد');
              Navigator.pop(ctx);
            },
            child: const Text(
              'خیر، انصراف',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              debugPrint('✅ [CONFLICT] کاربر تایید کرد سبد جدید ساخته شود');
              Navigator.pop(ctx);
              if (state.pendingItem != null &&
                  state.pendingMerchantId != null &&
                  state.pendingCategoryId != null) {
                debugPrint('🛒 [CONFLICT] ارسال ClearCartAndAddItem');
                getIt<CartBloc>().add(ClearCartAndAddItem(
                  item: state.pendingItem!,
                  merchantId: state.pendingMerchantId!,
                  categoryId: state.pendingCategoryId!,
                  lat: 30.5882768,
                  lng: 50.2575974,
                ));
              }
            },
            child: const Text(
              'بله، سبد جدید بساز',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== نتایج جستجو ====================
  Widget _buildSearchResults(
    BuildContext context,
    List<SearchCategoryItemDto> results,
    Color primaryColor,
  ) {
    debugPrint('🔍 [SEARCH_RESULTS] نمایش ${results.length} نتیجه جستجو');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.photo,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.category),
                ),
              ),
            ),
            title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: item.categoryDescription.isNotEmpty ? Text(item.categoryDescription) : null,
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              debugPrint('🔍 [SEARCH_RESULTS] انتخاب دسته: ${item.categoryName}');
              context.read<RestaurantBloc>().add(CategoryChanged(item.catId));
            },
          ),
        );
      },
    );
  }

  // ==================== نوار پایین سبد خرید ====================
  Widget _buildFloatingCartBar(
    BuildContext context,
    CartState cartState,
    Color primaryColor,
  ) {
    debugPrint('🛒 [CART_BAR] ساخت نوار پایین سبد خرید');
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () {
          debugPrint('🛒 [CART_BAR] رفتن به صفحه سبد خرید');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cartState.cartCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'مشاهده سبد خرید',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (cartState.status == CartStatus.updating)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Text(
                cartState.basketTotal,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== آیتم منو ====================
  Widget _buildMenuItem(
    MenuItemDto item,
    String categoryId,
    Color primaryColor,
    String merchantId,
    double lat,
    double lng,
    String merchantName,
    StoreType storeType,
    BuildContext context,
  ) {
    debugPrint('🍽️ [MENU_ITEM] رندر آیتم: ${item.name} (ID: ${item.id})');
    
    String formatPrice(String price) {
      if (price == 'نامشخص') return price;
      String cleaned = price.replaceAll(RegExp(r'تومان\s*تومان'), 'تومان').trim();
      if (!cleaned.contains('تومان')) {
        String numericPart = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
        if (numericPart.isNotEmpty) {
          final number = int.tryParse(numericPart) ?? 0;
          final formattedNumber = number.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
          cleaned = '$formattedNumber تومان';
        } else {
          cleaned = '$cleaned تومان';
        }
      }
      return cleaned;
    }

    return InkWell(
      onTap: () {
        debugPrint('🍽️ [MENU_ITEM] کلیک روی غذا: ${item.name} (ID: ${item.id})');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsPage(
              merchantId: merchantId,
              itemId: item.id,
              categoryId: categoryId,
              merchantName: merchantName,
              itemName: item.name,
              storeType: storeType,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description.isNotEmpty ? item.description : 'بدون توضیحات',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.price != 'نامشخص' ? formatPrice(item.price) : 'نامشخص',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          debugPrint('🛒 [MENU_ITEM] افزودن آیتم به سبد: ${item.name} (ID: ${item.id})');
                          final cartBloc = getIt<CartBloc>();
                          final restaurantRepo = getIt<RestaurantRepository>();
                          
                          final result = await restaurantRepo.getRestaurantInfo(
                            merchantId,
                            lat,
                            lng,
                          );
                          
                          result.fold(
                            (failure) {
                              debugPrint('❌ [MENU_ITEM] خطا در دریافت اطلاعات فروشگاه: ${failure.message}');
                            },
                            (info) {
                              debugPrint('📋 [MENU_ITEM] اطلاعات فروشگاه: نام=${info.name}, status="${info.status}"');
                              final isOpen = info.status == 'باز است' ||
                                  info.status == 'open' ||
                                  info.status == 'Open';
                              debugPrint('🔍 [MENU_ITEM] وضعیت فروشگاه: isOpen=$isOpen');
                              
                              if (!isOpen) {
                                debugPrint('⛔ [MENU_ITEM] فروشگاه بسته است!');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('این فروشگاه در حال حاضر غیرفعال است و امکان ثبت سفارش وجود ندارد.'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }
                              
                              debugPrint('✅ [MENU_ITEM] ارسال رویداد AddItemToCart');
                              cartBloc.add(AddItemToCart(
                                item: item,
                                merchantId: merchantId,
                                categoryId: categoryId,
                                lat: lat,
                                lng: lng,
                              ));
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'افزودن',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.photo,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== لودینگ شیمر ====================
  Widget _buildShimmerLoading(Color primaryColor) {
    debugPrint('⏳ [SHIMMER] نمایش لودینگ شیمر');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Column(
          children: [
            Container(height: 220, color: Colors.white),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ویجت جستجو با Debounce ====================
class _SearchTextField extends StatefulWidget {
  final StoreType storeType;
  final Function(String) onSearch;

  const _SearchTextField({
    required this.storeType,
    required this.onSearch,
  });

  @override
  State<_SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // ✅ لغو تایمر قبلی
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // ✅ اگر متن خالی بود، بلافاصله پاک کن
    if (query.trim().isEmpty) {
      widget.onSearch('');
      return;
    }

    // ✅ با تاخیر 500 میلی‌ثانیه اجرا کن
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        debugPrint('🔍 [SEARCH_DEBOUNCE] اجرای جستجو: "$query"');
        widget.onSearch(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.storeType.primaryColor;
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'جستجو در منو...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// ==================== دلیگیت دسته‌بندی ====================
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoryTabDelegate({required this.child});

  @override
  double get minExtent => 56.0;
  @override
  double get maxExtent => 56.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_CategoryTabDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}