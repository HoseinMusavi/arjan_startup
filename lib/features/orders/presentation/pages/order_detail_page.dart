import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/orders/domain/entities/order_entity.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_bloc.dart';
import 'package:arjan_startup/features/orders/presentation/pages/order_tracking_page.dart';
import 'package:arjan_startup/config/theme/app_theme.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final String merchantName;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.merchantName,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with SingleTickerProviderStateMixin {
  final OrderBloc _orderBloc = getIt<OrderBloc>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    
    debugPrint('📋 [OrderDetailPage] بارگذاری جزییات سفارش: ${widget.orderId}');
    _orderBloc.add(LoadOrderDetailEvent(
      orderId: widget.orderId,
      lat: 30.5882768,
      lng: 50.2575974,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<OrderBloc, OrderState>(
        bloc: _orderBloc,
        listener: (context, state) {
          if (state.status == OrderStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state.status == OrderStatus.loading) {
            return _buildShimmerLoading();
          }

          if (state.orderDetail == null) {
            return _buildEmptyWidget();
          }

          final detail = state.orderDetail!;
          
          return FadeTransition(
            opacity: _animationController,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusHeader(detail),
                  const SizedBox(height: 16),
                  _buildInfoCard(detail.infoItems),
                  const SizedBox(height: 16),
                  _buildProductsCard(detail.htmlContent),
                  const SizedBox(height: 16),
                  _buildTotalCard(detail),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: _buildBottomButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text(
            'جزئیات سفارش',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '#${widget.orderId}',
            style: const TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(OrderDetailEntity detail) {
    final status = _getOrderStatus(detail.infoItems);
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusInfo.color,
            statusInfo.color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: statusInfo.color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo.label,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سفارش ${widget.merchantName}',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getOrderDate(detail.infoItems),
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<OrderInfoItemEntity> infoItems) {
    final importantLabels = ['نام مشتری', 'نام فروشگاه', 'تلفن', 'نشانی', 'نوع تحویل', 'نوع پرداخت', 'تاریخ ثبت', 'تاریخ تحویل', 'زمان تحویل'];
    final filteredItems = infoItems.where((item) => importantLabels.contains(item.label)).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 22, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'اطلاعات سفارش',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: filteredItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              Icon(
                                _getInfoIcon(item.label),
                                size: 16,
                                color: AppTheme.textHint,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontFamily: 'Vazir',
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (index != filteredItems.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: AppTheme.dividerColor),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ بخش اصلاح شده - Html ویجت با تنظیمات صحیح برای نسخه 3
  Widget _buildProductsCard(String htmlContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 22, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'محصولات سفارش',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Html(
              data: htmlContent,
              style: {
                'body': Style(
                  backgroundColor: Colors.transparent,
                  fontSize: FontSize(14),
                  fontFamily: 'Vazir',
                ),
           '.item-order-list': Style(
  margin: Margins.only(bottom: 12),
  padding: HtmlPaddings.all(12),
  border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
),
                '.a': Style(
                  fontWeight: FontWeight.bold,
                ),
                '.b': Style(
                  fontWeight: FontWeight.w500,
                ),
                '.d': Style(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                '.cart_total': Style(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(16),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(OrderDetailEntity detail) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.receipt_outlined, size: 22, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'خلاصه صورتحساب',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTotalRow('جمع جزء', detail.subtotal),
                const SizedBox(height: 12),
                _buildTotalRow('هزینه ارسال', detail.deliveryCharges),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: AppTheme.dividerColor,
                ),
                const SizedBox(height: 12),
                _buildTotalRow('مبلغ قابل پرداخت', detail.total, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Vazir',
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Container(
          padding: isTotal ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) : null,
          decoration: isTotal
              ? BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                debugPrint('📋 [OrderDetailPage] ثبت مجدد سفارش: ${widget.orderId}');
                _orderBloc.add(ReOrderEvent(
                  orderId: widget.orderId,
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
                Navigator.pop(context);
              },
              icon: const Icon(Icons.repeat_outlined, size: 18),
              label: const Text('سفارش مجدد'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                debugPrint('📋 [OrderDetailPage] رفتن به صفحه پیگیری سفارش: ${widget.orderId}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingPage(orderId: widget.orderId),
                  ),
                );
              },
              icon: const Icon(Icons.track_changes_outlined, size: 18),
              label: const Text('پیگیری سفارش'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyWidget() {
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
            child: const Icon(Icons.receipt_long_outlined, size: 40, color: AppTheme.errorColor),
          ),
          const SizedBox(height: 20),
          const Text(
            'اطلاعاتی یافت نشد',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderDate(List<OrderInfoItemEntity> items) {
    const dateLabels = ['تاریخ ثبت', 'تاریخ تحویل'];
    for (final label in dateLabels) {
      final item = items.firstWhere(
        (i) => i.label == label,
        orElse: () => OrderInfoItemEntity(label: '', value: ''),
      );
      if (item.value.isNotEmpty) {
        return item.value;
      }
    }
    return 'تاریخ نامشخص';
  }

  String _getOrderStatus(List<OrderInfoItemEntity> items) {
    final statusItem = items.firstWhere(
      (i) => i.label == 'وضعیت',
      orElse: () => OrderInfoItemEntity(label: '', value: 'در حال پردازش'),
    );
    return statusItem.value;
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'انتظار':
        return const _StatusInfo(AppTheme.warningColor, Icons.access_time_rounded, 'در انتظار');
      case 'در حال پردازش':
        return const _StatusInfo(AppTheme.infoColor, Icons.propane_tank_outlined, 'در حال پردازش');
      case 'تکمیل شده':
        return const _StatusInfo(AppTheme.successColor, Icons.check_circle_rounded, 'تکمیل شده');
      case 'لغو شده':
        return const _StatusInfo(AppTheme.errorColor, Icons.cancel_rounded, 'لغو شده');
      default:
        return const _StatusInfo(AppTheme.primaryColor, Icons.shopping_bag_outlined, 'سفارش ثبت شده');
    }
  }

  IconData _getInfoIcon(String label) {
    switch (label) {
      case 'نام مشتری':
        return Icons.person_outline;
      case 'نام فروشگاه':
        return Icons.store_outlined;
      case 'تلفن':
        return Icons.phone_outlined;
      case 'نشانی':
        return Icons.location_on_outlined;
      case 'نوع تحویل':
        return Icons.delivery_dining_outlined;
      case 'نوع پرداخت':
        return Icons.payment_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;
  
  const _StatusInfo(this.color, this.icon, this.label);
}