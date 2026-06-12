import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/search_item_dto.dart';
import '../../../restaurant/presentation/pages/merchant_menu_page.dart';
import '../../../../core/enums/store_type.dart';

class SearchItemCard extends StatelessWidget {
  final SearchItemDto item;
  final StoreType storeType;

  const SearchItemCard({
    super.key,
    required this.item,
    this.storeType = StoreType.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = storeType.primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MerchantMenuPage(
                  merchantId: item.merchantId,
                  merchantName: item.title,
                  storeType: storeType,
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // لوگو
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.logo.isNotEmpty
                      ? item.logo
                      : 'https://arjanapp.ir/protected/modules/mobileappv2/assets/images/mobile-default-logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              // اطلاعات
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (item.subTitle.isNotEmpty)
                        Text(
                          item.subTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.storefront_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'فروشگاه: ${item.merchantId}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item.deliveryFee.isNotEmpty && item.deliveryFee != '0')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.motorcycle_outlined, size: 14, color: primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                'ارسال ${item.deliveryFee} تومان',
                                style: TextStyle(fontSize: 11, color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}