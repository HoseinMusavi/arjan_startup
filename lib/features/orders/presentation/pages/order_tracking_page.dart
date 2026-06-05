import 'package:flutter/material.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_bloc.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_event.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final OrderBloc _orderBloc = getIt<OrderBloc>();

  @override
  void initState() {
    super.initState();
    debugPrint('📍 [OrderTrackingPage] بررسی پیگیری سفارش: ${widget.orderId}');
    _orderBloc.add(CheckTrackEvent(
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
          'پیگیری سفارش #${widget.orderId}',
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
          }
        },
        builder: (context, state) {
          if (state.status == OrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusCard(primaryColor),
                const SizedBox(height: 16),
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildHelpCard(primaryColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Color primaryColor) {
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
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Text(
                  'وضعیت سفارش',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTimelineStep(
                  isCompleted: true,
                  title: 'ثبت سفارش',
                  time: '۱۴۰۵/۰۳/۱۰',
                  isFirst: true,
                ),
                _buildTimelineLine(isActive: true),
                _buildTimelineStep(
                  isCompleted: true,
                  title: 'تأیید فروشگاه',
                  time: '۱۴۰۵/۰۳/۱۰',
                ),
                _buildTimelineLine(isActive: true),
                _buildTimelineStep(
                  isCompleted: false,
                  title: 'آماده سازی سفارش',
                  time: 'در حال انجام',
                ),
                _buildTimelineLine(isActive: false),
                _buildTimelineStep(
                  isCompleted: false,
                  title: 'ارسال توسط پیک',
                  time: 'در انتظار',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required bool isCompleted,
    required String title,
    required String time,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.grey.shade300,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : const Icon(Icons.access_time, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: isCompleted ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine({required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Container(
        width: 2,
        height: 30,
        color: isActive ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildInfoCard() {
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
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 22),
                SizedBox(width: 12),
                Text(
                  'اطلاعات پیگیری',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('شماره سفارش', '#${widget.orderId}'),
                const SizedBox(height: 12),
                _buildInfoRow('وضعیت', 'در حال پردازش'),
                const SizedBox(height: 12),
                _buildInfoRow('آخرین بروزرسانی', '۱۴۰۵/۰۳/۱۰ ۲۱:۱۶'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildHelpCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.support_agent, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نیاز به کمک دارید؟',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'با پشتیبانی تماس بگیرید',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}