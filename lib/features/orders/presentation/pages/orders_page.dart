import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_bloc.dart';
import 'package:arjan_startup/features/orders/presentation/widgets/order_card.dart';
import 'package:arjan_startup/features/orders/presentation/widgets/order_search_bar.dart';
import 'package:arjan_startup/features/orders/presentation/pages/order_detail_page.dart';
import 'package:arjan_startup/features/orders/presentation/pages/order_tracking_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderBloc _orderBloc = getIt<OrderBloc>();
  final List<String> _tabs = const ['همه', 'در حال پردازش', 'تکمیل شده', 'لغو شده'];
  final List<String> _tabValues = const ['all', 'processing', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadOrders(_tabValues[_tabController.index]);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final tabValue = _tabValues[_tabController.index];
      debugPrint('📋 [OrdersPage] تغییر تب به: $tabValue');
      _loadOrders(tabValue);
    }
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
    final currentTabValue = _tabValues[_tabController.index];
    _orderBloc.add(RefreshOrdersEvent(lat: 30.5882768, lng: 50.2575974));
    _loadOrders(currentTabValue);
  }

  void _onReorder(String orderId) {
    debugPrint('📋 [OrdersPage] ثبت مجدد سفارش: $orderId');
    _orderBloc.add(ReOrderEvent(
      orderId: orderId,
      lat: 30.5882768,
      lng: 50.2575974,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('آیتم‌ها به سبد خرید اضافه شد'), backgroundColor: Colors.green),
    );
  }

  void _onTrack(String orderId) {
    debugPrint('📋 [OrdersPage] پیگیری سفارش: $orderId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingPage(orderId: orderId),
      ),
    );
  }

  void _onOrderTap(String orderId, String merchantName) {
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
    const Color primaryColor = Color(0xFFFF7A00);
    const Color bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'سفارشات من',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'همه'),
            Tab(text: 'در حال پردازش'),
            Tab(text: 'تکمیل شده'),
            Tab(text: 'لغو شده'),
          ],
          labelColor: Color(0xFFFF7A00),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFFF7A00),
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      body: Column(
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
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.isSearching) {
                  return _buildSearchResults(state, primaryColor);
                }

                if (state.status == OrderStatus.loading) {
                  return _buildLoadingShimmer();
                }

                if (state.status == OrderStatus.failure) {
                  return _buildErrorWidget(primaryColor);
                }

                if (state.status == OrderStatus.empty || state.orders.isEmpty) {
                  return _buildEmptyWidget(primaryColor);
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: primaryColor,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => _onOrderTap(order.orderId, order.merchantName),
                        onReorder: () => _onReorder(order.orderId),
                        onTrack: order.addTrack ? () => _onTrack(order.orderId) : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(OrderState state, Color primaryColor) {
    if (state.status == OrderStatus.loading) {
      return _buildLoadingShimmer();
    }

    if (state.status == OrderStatus.failure) {
      return _buildErrorWidget(primaryColor);
    }

    if (state.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'نتیجه‌ای یافت نشد',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'عبارت دیگری را جستجو کنید',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final item = state.searchResults[index];
        return OrderCard(
          searchResult: item,
          onTap: () => _onOrderTap(item.orderId, item.restaurantName),
          onReorder: () => _onReorder(item.orderId),
          onTrack: null,
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorWidget(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری سفارشات',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadOrders(_tabValues[_tabController.index]),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'سفارشی یافت نشد',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'سفارش‌های شما در این بخش نمایش داده می‌شوند',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('مشاهده فروشگاه‌ها'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}