import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/restaurant/presentation/bloc/restaurant_bloc.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';

class MerchantMenuPage extends StatelessWidget {
  final String merchantId;
  final String merchantName;

  const MerchantMenuPage({
    super.key, 
    required this.merchantId,
    required this.merchantName,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);
    const double lat = 30.5882768;
    const double lng = 50.2575974;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<RestaurantBloc>()..add(RestaurantStarted(merchantId, lat, lng))),
        // ✅ استفاده از Bloc سراسری برای جلوگیری از پاک شدن سبد خرید هنگام خروج از صفحه
        BlocProvider.value(value: getIt<CartBloc>()..add(LoadCartCount(merchantId, lat, lng))),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: BlocBuilder<RestaurantBloc, RestaurantState>(
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
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    category.name,
                                    style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
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
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primaryColor)))
                else if (state.items.isEmpty)
                  const SliverFillRemaining(child: Center(child: Text('آیتمی در این دسته وجود ندارد')))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildMenuItem(context, state.items[index], state.selectedCategoryId, primaryColor, merchantId, lat, lng);
                      },
                      childCount: state.items.length,
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () { // ✅ ارور حل شد (onTap به onPressed تغییر کرد)
          // انتقال به سبد خرید در فازهای بعدی
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

  Widget _buildMenuItem(BuildContext context, MenuItemDto item, String categoryId, Color primaryColor, String merchantId, double lat, double lng) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(item.description.isNotEmpty ? item.description : 'بدون توضیحات', style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.price != 'نامشخص' ? '${item.price} تومان' : 'نامشخص', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: primaryColor)),
                    InkWell(
                      onTap: () {
                        context.read<CartBloc>().add(AddItemToCart(item: item, merchantId: merchantId, categoryId: categoryId, lat: lat, lng: lng));
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text('افزودن', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.photo, width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey.shade100, child: const Icon(Icons.fastfood, color: Colors.grey)))),
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