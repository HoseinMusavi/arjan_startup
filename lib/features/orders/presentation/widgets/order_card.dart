import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:arjan_startup/features/orders/domain/entities/order_entity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity? order;
  final dynamic searchResult;
  final VoidCallback onTap;
  final VoidCallback onReorder;
  final VoidCallback? onTrack;

  const OrderCard({
    super.key,
    this.order,
    this.searchResult,
    required this.onTap,
    required this.onReorder,
    this.onTrack,
  });

  String getOrderId() {
    if (order != null) return order!.orderId;
    if (searchResult != null) return searchResult.orderId;
    return '';
  }

  String getMerchantName() {
    if (order != null) return order!.merchantName;
    if (searchResult != null) return searchResult.restaurantName;
    return '';
  }

  String getLogo() {
    if (order != null) return order!.logo;
    if (searchResult != null) return searchResult.logo;
    return '';
  }

  String getTotal() {
    if (order != null) return order!.totalWTax;
    if (searchResult != null) return searchResult.totalWTax;
    return '';
  }

  String getStatus() {
    if (order != null) return order!.status;
    return '';
  }

  String getDate() {
    if (order != null) return order!.dateCreated;
    return '';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'انتظار':
        return Colors.orange;
      case 'در حال پردازش':
        return Colors.blue;
      case 'تکمیل شده':
        return Colors.green;
      case 'لغو شده':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);
    final orderId = getOrderId();
    final merchantName = getMerchantName();
    final logo = getLogo();
    final total = getTotal();
    final status = getStatus();
    final date = getDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ردیف بالایی: لوگو، نام فروشگاه، وضعیت
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: logo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: logo,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.storefront, color: Colors.grey, size: 28),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.storefront, color: Colors.grey, size: 28),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchantName.isNotEmpty ? merchantName : 'نامشخص',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'شماره سفارش: #$orderId',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ردیف میانی: تاریخ و مبلغ
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      date.isNotEmpty ? date : 'تاریخ نامشخص',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      total,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // دکمه‌های اقدام
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReorder,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'سفارش مجدد',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (onTrack != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTrack,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.green.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'پیگیری',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.green),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'جزئیات',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}