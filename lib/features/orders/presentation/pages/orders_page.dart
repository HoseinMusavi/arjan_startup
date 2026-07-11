import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_bloc.dart';
import 'package:arjan_startup/features/orders/presentation/widgets/order_card.dart';
import 'package:arjan_startup/features/orders/presentation/widgets/order_search_bar.dart';
import 'package:arjan_startup/features/orders/presentation/pages/order_detail_page.dart';
import 'package:arjan_startup/features/orders/presentation/pages/order_tracking_page.dart';
import 'package:arjan_startup/config/theme/app_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderBloc _orderBloc = getIt<OrderBloc>();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  
  final List<String> _tabs = const ['همه', 'در حال پردازش', 'تکمیل شده', 'لغو شده'];
  final List<String> _tabValues = const ['all', 'processing', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadOrders(_tabValues[_tabController.index]);
    
    //监听滚动 برای نمایش دکمه بازگشت به بالا
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 500 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.position.pixels <= 500 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final tabValue = _tabValues[_tabController.index];
      debugPrint('📋 [OrdersPage] تغییر تب به: $tabValue');
      _safeScrollToTop();
      _loadOrders(tabValue);
    }
  }

  void _safeScrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _loadOrders(String tab) {
    debugPrint('📋 [OrdersPage] ارسال رویداد LoadOrdersEvent - tab: $tab');
    _orderBloc.add(LoadOrdersEvent(
      tab: tab,
      lat: 30.5882768,
      lng: 50.2575974,
    ));
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    final currentTabValue = _tabValues[_tabController.index];
    _orderBloc.add(RefreshOrdersEvent(lat: 30.5882768, lng: 50.2575974));
    await Future.delayed(const Duration(milliseconds: 500));
    _loadOrders(currentTabValue);
  }

  void _onReorder(String orderId) {
    HapticFeedback.lightImpact();
    debugPrint('📋 [OrdersPage] ثبت مجدد سفارش: $orderId');
    _orderBloc.add(ReOrderEvent(
      orderId: orderId,
      lat: 30.5882768,
      lng: 50.2575974,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('آیتم‌ها به سبد خرید اضافه شد'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTrack(String orderId) {
    HapticFeedback.lightImpact();
    debugPrint('📋 [OrdersPage] پیگیری سفارش: $orderId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingPage(orderId: orderId),
      ),
    );
  }

  void _onOrderTap(String orderId, String merchantName) {
    HapticFeedback.lightImpact();
    debugPrint('📋 [OrdersPage] کلیک روی سفارش: $orderId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          orderId: orderId,
          merchantName: merchantName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              OrderSearchBar(
                onSearch: (query) {
                  if (query.trim().isNotEmpty) {
                    _orderBloc.add(SearchOrderEvent(
                      searchStr: query,
                      lat: 30.5882768,
                      lng: 50.2575974,
                    ));
                  } else {
                    _orderBloc.add(ClearSearchEvent());
                    _loadOrders(_tabValues[_tabController.index]);
                  }
                },
                onClear: () {
                  _orderBloc.add(ClearSearchEvent());
                  _loadOrders(_tabValues[_tabController.index]);
                },
              ),
              Expanded(
                child: BlocConsumer<OrderBloc, OrderState>(
                  bloc: _orderBloc,
                  listener: (context, state) {
                    if (state.status == OrderStatus.failure && state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(state.errorMessage!)),
                            ],
                          ),
                          backgroundColor: AppTheme.errorColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.isSearching) {
                      return _buildSearchResults(state);
                    }

                    if (state.status == OrderStatus.loading && state.orders.isEmpty) {
                      return _buildShimmerLoading();
                    }

                    if (state.status == OrderStatus.failure) {
                      return _buildErrorWidget();
                    }

                    if (state.status == OrderStatus.empty || state.orders.isEmpty) {
                      return _buildEmptyWidget();
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      displacement: 40,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(14),
                        itemCount: state.orders.length,
                        itemBuilder: (context, index) {
                          final order = state.orders[index];
                          return AnimatedOpacity(
                            opacity: 1,
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            child: Transform.translate(
                              offset: const Offset(0, 0),
                              child: OrderCard(
                                order: order,
                                onTap: () => _onOrderTap(order.orderId, order.merchantName),
                                onReorder: () => _onReorder(order.orderId),
                                onTrack: order.addTrack ? () => _onTrack(order.orderId) : null,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // دکمه بازگشت به بالا
          if (_showBackToTop)
            Positioned(
              bottom: 20,
              right: 16,
              child: _buildBackToTopButton(),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: const SizedBox(),
      title: const Text(
        'سفارشات من',
        style: TextStyle(
          fontFamily: 'Vazir',
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => _buildTab(tab)).toList(),
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontFamily: 'Vazir',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Vazir',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            physics: const BouncingScrollPhysics(),
            isScrollable: false,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title),
    );
  }

  Widget _buildBackToTopButton() {
    return GestureDetector(
      onTap: _scrollToTop,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // ✅ اسکلتون شیمر حرفه‌ای
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: ShimmerCard(),
        );
      },
    );
  }

  Widget _buildSearchResults(OrderState state) {
    if (state.status == OrderStatus.loading) {
      return _buildShimmerLoading();
    }

    if (state.status == OrderStatus.failure) {
      return _buildErrorWidget();
    }

    if (state.searchResults.isEmpty) {
      return _buildEmptySearchWidget();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final item = state.searchResults[index];
        return AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 200 + (index * 30)),
          child: OrderCard(
            searchResult: item,
            onTap: () => _onOrderTap(item.orderId, item.restaurantName),
            onReorder: () => _onReorder(item.orderId),
            onTrack: null,
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'خطا در بارگذاری سفارشات',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لطفاً اتصال اینترنت خود را بررسی کنید',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _loadOrders(_tabValues[_tabController.index]),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'سفارشی یافت نشد',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'شما هنوز هیچ سفارشی ثبت نکرده‌اید',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('مشاهده فروشگاه‌ها'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'نتیجه‌ای یافت نشد',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عبارت دیگری را جستجو کنید',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

// ✅ ویجت اسکلتون شیمر جداگانه
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // شیمیر لوگو
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
                  ),
                ),
                const SizedBox(width: 12),
                // شیمیر متن‌ها
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                // شیمیر وضعیت
                Container(
                  width: 70,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(24),
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
}