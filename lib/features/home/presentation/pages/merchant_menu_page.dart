import 'package:arjan_startup/features/cart/presentation/pages/cart_page.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/restaurant/presentation/bloc/restaurant_bloc.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';

class MerchantMenuPage extends StatefulWidget {
  final String merchantId;
  final String merchantName;

  const MerchantMenuPage({
    super.key, 
    required this.merchantId,
    required this.merchantName,
  });

  @override
  State<MerchantMenuPage> createState() => _MerchantMenuPageState();
}

class _MerchantMenuPageState extends State<MerchantMenuPage> {
  @override
  void initState() {
    super.initState();
    getIt<CartBloc>().add(LoadCartCount(widget.merchantId, 30.5882768, 50.2575974));
  }

  void _showConflictDialog(BuildContext context, CartState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('سبد خرید فعال است!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('شما محصولاتی از یک رستوران دیگر در سبد خرید دارید. برای خرید از این رستوران، سبد قبلی حذف خواهد شد. موافقید؟', style: TextStyle(height: 1.5, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('خیر، انصراف', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);

    return BlocProvider(
      create: (context) => getIt<RestaurantBloc>()..add(RestaurantStarted(widget.merchantId, 30.5882768, 50.2575974)),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: MultiBlocListener(
          listeners: [
            // ✅ لیسنر برای دیالوگ تداخل رستوران
            BlocListener<CartBloc, CartState>(
              bloc: getIt<CartBloc>(),
              listenWhen: (previous, current) => current.status == CartStatus.conflict,
              listener: (context, state) {
                if (state.status == CartStatus.conflict) {
                  _showConflictDialog(context, state);
                }
              },
            ),
            // ✅✅✅ لیسنر جدید برای نمایش پیام خطا (مثل فروشگاه غیرفعال) ✅✅✅
         BlocListener<CartBloc, CartState>(
  bloc: getIt<CartBloc>(),
  listenWhen: (previous, current) => 
      current.status == CartStatus.failure && current.errorMessage.isNotEmpty,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    // ✅ بعد از نمایش خطا، وضعیت رو ریست کن تا دفعه بعد دوباره کار کنه
    Future.delayed(const Duration(milliseconds: 100), () {
      getIt<CartBloc>().emit(state.copyWith(status: CartStatus.success, errorMessage: ''));
    });
  },
),
          ],
          child: BlocBuilder<RestaurantBloc, RestaurantState>(
            builder: (context, state) {
              if (state.status == RestaurantStatus.initial || state.status == RestaurantStatus.loading) {
                return _buildShimmerLoading();
              }

              if (state.status == RestaurantStatus.failure) {
                return Center(child: Text(state.errorMessage));
              }

              final info = state.info;
              if (info == null) return const Center(child: Text('اطلاعات یافت نشد'));

              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(info, primaryColor),
                  
                  if (state.categories.isNotEmpty)
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
                                    decoration: BoxDecoration(color: isSelected ? primaryColor : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                                    alignment: Alignment.center,
                                    child: Text(category.name, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  if (state.menuStatus == MenuLoadingStatus.loading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primaryColor)))
                  else if (state.items.isEmpty)
                    const SliverFillRemaining(child: Center(child: Text('آیتمی در این دسته وجود ندارد')))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildMenuItem(state.items[index], state.selectedCategoryId, primaryColor, widget.merchantId, 30.5882768, 50.2575974);
                        },
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
              return _buildFloatingCartBar(cartState);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFloatingCartBar(CartState cartState) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -3))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Text('${cartState.cartCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
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

  Widget _buildMenuItem(MenuItemDto item, String categoryId, Color primaryColor, String merchantId, double lat, double lng) {
  return Container(
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
                    child: Text(item.price != 'نامشخص' ? '${item.price} تومان' : 'نامشخص', 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: primaryColor), 
                      overflow: TextOverflow.ellipsis, 
                      maxLines: 1),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      // ✅ چک کردن وضعیت فروشگاه قبل از افزودن به سبد
                      final cartBloc = getIt<CartBloc>();
                      final restaurantRepo = getIt<RestaurantRepository>();
                      final result = await restaurantRepo.getRestaurantInfo(merchantId, lat, lng);
                      
                      result.fold(
                        (failure) => null,
                        (info) {
                          // بررسی باز بودن فروشگاه
                          if (info.status != 'باز است' && info.status != 'open' && info.status != 'Open') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('این فروشگاه در حال حاضر غیرفعال است و امکان ثبت سفارش وجود ندارد.'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          // اگر فروشگاه باز بود، به سبد خرید اضافه کن
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
                        color: Colors.orange.shade50,
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
  );
}

  Widget _buildSliverAppBar(RestaurantInfoDto info, Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 220, pinned: true, backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black87),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(info.backgroundUrl.isNotEmpty ? info.backgroundUrl : info.logo, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200)),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.white]))),
            Positioned(
              bottom: 16, right: 16,
              child: Row(
                children: [
                  Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]), child: ClipOval(child: Image.network(info.logo, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood)))),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Row(children: [Icon(Icons.star, color: Colors.orange.shade400, size: 16), const SizedBox(width: 4), Text('${info.rating} • ${info.cuisine}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13))]),
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

  Widget _buildShimmerLoading() {
    return Scaffold(backgroundColor: Colors.white, body: Shimmer.fromColors(baseColor: Colors.grey.shade200, highlightColor: Colors.grey.shade50, child: Column(children: [Container(height: 220, color: Colors.white), const SizedBox(height: 16), Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 40, color: Colors.white), const SizedBox(height: 24), Expanded(child: ListView.builder(itemCount: 5, itemBuilder: (context, index) => Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))))])));
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