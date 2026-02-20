import 'package:flutter/material.dart';
import '../../data/models/merchant_dto.dart';

class MerchantCard extends StatelessWidget {
  final MerchantDto merchant;
  final bool isHorizontal;

  const MerchantCard({
    super.key,
    required this.merchant,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);

    return Container(
      width: isHorizontal ? 280 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کاور رستوران و لوگوی شناور
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  merchant.background.isNotEmpty ? merchant.background : merchant.logo,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 130,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              // لایه تیره کننده برای زیبایی
              Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                  ),
                ),
              ),
              // لوگوی رستوران
              Positioned(
                bottom: -20,
                right: 16,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      merchant.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28), // فضای جبرانی لوگوی شناور
          
          // اطلاعات رستوران
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        merchant.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            merchant.rating.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade700),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star_rounded, color: Colors.green.shade700, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  merchant.cuisineText.isNotEmpty ? merchant.cuisineText : 'فست فود، پیتزا',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.motorcycle_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      merchant.deliveryFee == '0' || merchant.deliveryFee.isEmpty 
                          ? 'ارسال رایگان' 
                          : 'ارسال ${merchant.deliveryFee} تومان', 
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}