import 'dart:async';
import 'package:arjan_startup/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:arjan_startup/features/restaurant/presentation/bloc/restaurant_bloc.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/search_category_item_dto.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/restaurant/presentation/pages/item_details_page.dart';
import 'package:arjan_startup/features/restaurant/presentation/pages/merchant_about_page.dart';
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
    final Color primaryColor = storeType.primaryColor;
    final TextEditingController searchController = TextEditingController();

    return BlocProvider(
      create: (context) => RestaurantBloc(getIt<RestaurantRepository>())
        ..add(RestaurantStarted(merchantId, 30.5882768, 50.2575974)),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(merchantName),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
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
              tooltip: 'اطلاعات رستوران',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _SearchTextField(
                storeType: storeType,
                controller: searchController,
              ),
            ),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<CartBloc, CartState>(
              bloc: getIt<CartBloc>(),
              listenWhen: (previous, current) => current.status == CartStatus.conflict,
              listener: (context, state) => _showConflictDialog(context, state, primaryColor),
            ),
            BlocListener<CartBloc, CartState>(
              bloc: getIt<CartBloc>(),
              listenWhen: (previous, current) =>
                  current.status == CartStatus.failure && current.errorMessage.isNotEmpty,
              listener: (context, state) {
                debugPrint('❌ [MERCHANT_PAGE] خطا: ${state.errorMessage}');
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
              if (state.searchMenuStatus == SearchMenuStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.searchMenuStatus == SearchMenuStatus.success && state.searchResults.isNotEmpty) {
                return _buildSearchResults(
                  context,
                  state.searchResults,
                  primaryColor,
                  searchController,
                );
              }
              if (state.searchMenuStatus == SearchMenuStatus.empty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('نتیجه‌ای برای "${state.searchQuery}" یافت نشد', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }
              if (state.searchMenuStatus == SearchMenuStatus.failure) {
                return Center(child: Text('خطا در جستجو: ${state.errorMessage}'));
              }

              if (state.status == RestaurantStatus.initial || state.status == RestaurantStatus.loading) {
                return _buildShimmerLoading(primaryColor);
              }
              if (state.status == RestaurantStatus.failure) {
                return Center(child: Text(state.errorMessage));
              }
              final info = state.info;
              if (info == null) return const Center(child: Text('اطلاعات یافت نشد'));

              return CustomScrollView(
                slivers: [
                  if (storeType != StoreType.supermarket && state.categories.isNotEmpty)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryTabDelegate(
                        child: Container(
                          color: Colors.white,
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            itemCount: state.categories.length,
                            itemBuilder: (context, index) {
                              final category = state.categories[index];
                              final isSelected = state.selectedCategoryId == category.id;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => context.read<RestaurantBloc>().add(CategoryChanged(category.id)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryColor : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      category.name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey.shade700,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  if (state.menuStatus == MenuLoadingStatus.loading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  else if (state.items.isEmpty)
                    const SliverFillRemaining(child: Center(child: Text('آیتمی در این دسته وجود ندارد')))
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
              return _buildFloatingCartBar(context, cartState, primaryColor);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showConflictDialog(BuildContext context, CartState state, Color primaryColor) {
    debugPrint('⚠️ [MERCHANT_PAGE] نمایش دیالوگ تداخل سبد خرید');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('سبد خرید فعال است!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('شما محصولاتی از یک فروشگاه دیگر در سبد خرید دارید. برای خرید از این فروشگاه، سبد قبلی حذف خواهد شد. موافقید؟', style: TextStyle(height: 1.5, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('خیر، انصراف', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              debugPrint('✅ [MERCHANT_PAGE] کاربر تایید کرد سبد جدید ساخته شود');
              Navigator.pop(ctx);
              if (state.pendingItem != null && state.pendingMerchantId != null && state.pendingCategoryId != null) {
                getIt<CartBloc>().add(ClearCartAndAddItem(
                  item: state.pendingItem!,
                  merchantId: state.pendingMerchantId!,
                  categoryId: state.pendingCategoryId!,
                  lat: 30.5882768,
                  lng: 50.2575974,
                ));
              }
            },
            child: const Text('بله، سبد جدید بساز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<SearchCategoryItemDto> results,
    Color primaryColor,
    TextEditingController searchController,
  ) {
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
              searchController.clear();
              context.read<RestaurantBloc>().add(CategoryChanged(item.catId));
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingCartBar(BuildContext context, CartState cartState, Color primaryColor) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16)),
        onPressed: () {
          debugPrint('🛒 [MERCHANT_PAGE] رفتن به صفحه سبد خرید');
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Text('${cartState.cartCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                const Text('مشاهده سبد خرید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            if (cartState.status == CartStatus.updating)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            else
              Text(cartState.basketTotal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

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
    String formatPrice(String price) {
      if (price == 'نامشخص') return price;
      String cleaned = price.replaceAll(RegExp(r'تومان\s*تومان'), 'تومان').trim();
      if (!cleaned.contains('تومان')) {
        String numericPart = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
        if (numericPart.isNotEmpty) {
          final number = int.tryParse(numericPart) ?? 0;
          final formattedNumber = number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
          cleaned = '$formattedNumber تومان';
        } else {
          cleaned = '$cleaned تومان';
        }
      }
      return cleaned;
    }

    return InkWell(
      onTap: () {
        debugPrint('🍽️ [MENU] کلیک روی غذا: ${item.name} (ID: ${item.id})');
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(item.description.isNotEmpty ? item.description : 'بدون توضیحات', style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.price != 'نامشخص' ? formatPrice(item.price) : 'نامشخص',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: primaryColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          debugPrint('🛒 [MENU] شروع افزودن آیتم: ${item.name} (ID: ${item.id}) به فروشگاه: $merchantId');
                          final cartBloc = getIt<CartBloc>();
                          final restaurantRepo = getIt<RestaurantRepository>();
                          debugPrint('📡 [MENU] درخواست بررسی وضعیت فروشگاه: $merchantId');
                          final result = await restaurantRepo.getRestaurantInfo(merchantId, lat, lng);
                          result.fold(
                            (failure) {
                              debugPrint('❌ [MENU] خطا در دریافت اطلاعات فروشگاه: ${failure.message}');
                            },
                            (info) {
                              debugPrint('📋 [MENU] اطلاعات فروشگاه دریافت شد: نام=${info.name}, status="${info.status}"');
                              final isOpen = info.status == 'باز است' || info.status == 'open' || info.status == 'Open';
                              debugPrint('🔍 [MENU] وضعیت فروشگاه: isOpen=$isOpen, status="${info.status}"');
                              if (!isOpen) {
                                debugPrint('⛔ [MENU] فروشگاه بسته است! نمایش پیام خطا');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('این فروشگاه در حال حاضر غیرفعال است و امکان ثبت سفارش وجود ندارد.'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }
                              debugPrint('✅ [MENU] فروشگاه باز است، ارسال رویداد AddItemToCart');
                              cartBloc.add(AddItemToCart(
                                item: item,
                                merchantId: merchantId,
                                categoryId: categoryId,
                                lat: lat,
                                lng: lng,
                              ));
                              debugPrint('📤 [MENU] رویداد AddItemToCart ارسال شد');
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('افزودن', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildShimmerLoading(Color primaryColor) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Column(
          children: [
            Container(height: 220, color: Colors.white),
            const SizedBox(height: 16),
            Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 40, color: Colors.white),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 100,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTextField extends StatefulWidget {
  final StoreType storeType;
  final TextEditingController controller;

  const _SearchTextField({
    required this.storeType,
    required this.controller,
  });

  @override
  State<_SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      context.read<RestaurantBloc>().add(const ClearSearch());
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<RestaurantBloc>().add(SearchMenu(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.storeType.primaryColor;
    return TextField(
      controller: widget.controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'جستجو در منو...',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade500),
                onPressed: () {
                  widget.controller.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoryTabDelegate({required this.child});
  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);
  @override
  bool shouldRebuild(_CategoryTabDelegate oldDelegate) => child != oldDelegate.child;
}