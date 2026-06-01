import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:flutter/material.dart';
import '../../data/models/merchant_dto.dart';
import '../../../restaurant/presentation/pages/merchant_menu_page.dart';

class MerchantCard extends StatelessWidget {
  final MerchantDto merchant;
  final bool isHorizontal;
  final StoreType storeType;

  const MerchantCard({
    super.key,
    required this.merchant,
    this.isHorizontal = false,
    this.storeType = StoreType.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = storeType.primaryColor;
    final bool isFreeDelivery = merchant.deliveryFee == '0' || merchant.deliveryFee.isEmpty;

    return Container(
      width: isHorizontal ? 270 : double.infinity,
      margin: EdgeInsets.only(bottom: isHorizontal ? 0 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MerchantMenuPage(
                  merchantId: merchant.id,
                  merchantName: merchant.name,
                  storeType: storeType,  // ✅ این خط رو حتما اضافه کن
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: 2.3,
                      child: Image.network(
                        merchant.background.isNotEmpty ? merchant.background : merchant.logo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.storefront_rounded, color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.black54),
                    ),
                  ),
                  if (merchant.distance.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              merchant.distance,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: -24,
                    right: 16,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          merchant.logo.isNotEmpty ? merchant.logo : 'https://arjanapp.ir/protected/modules/mobileappv2/assets/images/default_bg.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                merchant.rating > 0 ? merchant.rating.toString() : 'جدید',
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
                      merchant.cuisineText.isNotEmpty ? merchant.cuisineText : (storeType == StoreType.supermarket ? 'سوپرمارکت' : 'فست فود • ایرانی'),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isFreeDelivery ? primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.motorcycle_outlined,
                            size: 15,
                            color: isFreeDelivery ? primaryColor : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isFreeDelivery ? 'ارسال رایگان' : 'ارسال ${merchant.deliveryFee} تومان',
                          style: TextStyle(
                            fontSize: 12,
                            color: isFreeDelivery ? primaryColor : Colors.grey.shade700,
                            fontWeight: isFreeDelivery ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (merchant.openStatus.contains('بسته') || merchant.openStatus.contains('close'))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'بسته',
                              style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}