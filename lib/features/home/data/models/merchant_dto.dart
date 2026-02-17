import 'package:equatable/equatable.dart';

class MerchantDto extends Equatable {
  final String id;
  final String name;
  final String cuisine;
  final String logo;
  final String distance;
  final String deliveryTime;
  final String rating;
  final bool isOpen;

  const MerchantDto({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.logo,
    required this.distance,
    required this.deliveryTime,
    required this.rating,
    required this.isOpen,
  });

  factory MerchantDto.fromJson(Map<String, dynamic> json) {
    // پارس کردن وضعیت باز بودن (طبق لاگ: open_status_raw: "open" یا "pre-order")
    final String statusRaw = json['open_status_raw']?.toString() ?? '';
    final bool isOpen = statusRaw == 'open' || statusRaw == 'open_for_delivery';

    // پارس کردن امتیاز (rating یک آبجکت است)
    String ratingVal = "0";
    if (json['rating'] is Map) {
      ratingVal = json['rating']['votes']?.toString() ?? "0";
    }

    return MerchantDto(
      id: json['merchant_id']?.toString() ?? '',
      // طبق لاگ شما نام رستوران در restaurant_name است
      name: json['restaurant_name']?.toString() ?? '', 
      cuisine: json['cuisine']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      // طبق لاگ، distance_plot فرمت شده است (مثلا 0.3 کیلومتر)
      distance: json['distance_plot']?.toString() ?? '', 
      deliveryTime: json['delivery_estimation']?.toString() ?? '20-30 min',
      rating: ratingVal,
      isOpen: isOpen,
    );
  }

  @override
  List<Object?> get props => [id, name];
}