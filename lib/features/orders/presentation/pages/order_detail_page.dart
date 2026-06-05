import 'package:arjan_startup/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_bloc.dart';
import 'package:arjan_startup/features/orders/presentation/pages/order_tracking_page.dart';

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

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderBloc _orderBloc = getIt<OrderBloc>();

  @override
  void initState() {
    super.initState();
    debugPrint('📋 [OrderDetailPage] بارگذاری جزییات سفارش: ${widget.orderId}');
    _orderBloc.add(LoadOrderDetailEvent(
      orderId: widget.orderId,
      lat: 30.5882768,
      lng: 50.2575974,
    ));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'جزییات سفارش #${widget.orderId}',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        bloc: _orderBloc,
        listener: (context, state) {
          if (state.status == OrderStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state.status == OrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.orderDetail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'اطلاعاتی یافت نشد',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final detail = state.orderDetail!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoCard(detail.infoItems, primaryColor),
                const SizedBox(height: 12),
                _buildProductsCard(detail.htmlContent, primaryColor),
                const SizedBox(height: 12),
                _buildTotalCard(detail, primaryColor),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomSheet: _buildBottomButtons(primaryColor),
    );
  }

  Widget _buildInfoCard(List<OrderInfoItemEntity> infoItems, Color primaryColor) {
    final importantLabels = ['نام مشتری', 'نام فروشگاه', 'تلفن', 'نشانی', 'نوع تحویل', 'نوع پرداخت', 'تاریخ ثبت', 'تاریخ تحویل', 'زمان تحویل'];
    final filteredItems = infoItems.where((item) => importantLabels.contains(item.label)).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'اطلاعات سفارش',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: filteredItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          item.label,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(String htmlContent, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'محصولات سفارش',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Html(
              data: htmlContent,
              style: {
                'body': Style(
                  backgroundColor: Colors.transparent,
                  fontSize:  FontSize(14),
                ),
                // '.item-order-list': Style(
                //   margin:  EdgeInsets.only(bottom: 12),
                //   padding:  EdgeInsets.all(12),
                //   border:  Border.all(color: Colors.grey),
                // ),
                '.a': Style(
                  fontWeight: FontWeight.bold,
                ),
                '.b': Style(
                  fontWeight: FontWeight.w500,
                ),
                '.d': Style(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                '.cart_total': Style(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize:  FontSize(16),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(OrderDetailEntity detail, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'خلاصه صورتحساب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTotalRow('جمع جزء', detail.subtotal),
                const SizedBox(height: 12),
                _buildTotalRow('هزینه ارسال', detail.deliveryCharges),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 12),
                _buildTotalRow('مبلغ قابل پرداخت', detail.total, isTotal: true, primaryColor: primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, String value, {bool isTotal = false, Color? primaryColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(Color primaryColor) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                debugPrint('📋 [OrderDetailPage] ثبت مجدد سفارش: ${widget.orderId}');
                _orderBloc.add(ReOrderEvent(
                  orderId: widget.orderId,
                  lat: 30.5882768,
                  lng: 50.2575974,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('آیتم‌ها به سبد خرید اضافه شد'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('سفارش مجدد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                debugPrint('📋 [OrderDetailPage] رفتن به صفحه پیگیری سفارش: ${widget.orderId}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingPage(orderId: widget.orderId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('پیگیری سفارش', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}