import 'package:flutter/foundation.dart';

class MerchantDto {
  final String id;
  final String name;
  final String logo;
  final String background;
  final String cuisineText;
  final String distance;
  final double rating;
  final String deliveryFee;
  final String openStatus;
  final String openStatusRaw;  // مقدار خام از سرور
  final String cuisineId;

  MerchantDto({
    required this.id,
    required this.name,
    required this.logo,
    required this.background,
    required this.cuisineText,
    required this.distance,
    required this.rating,
    required this.deliveryFee,
    required this.openStatus,
    required this.openStatusRaw,
    required this.cuisineId,
  });

  // آیا فروشگاه باز است؟
  bool get isOpen {
    return openStatusRaw == 'open' ||
        openStatusRaw == 'pre-order' ||
        openStatus.contains('باز') ||
        openStatus.contains('پیش سفارش');
  }

  factory MerchantDto.fromJson(Map<String, dynamic> json) {
    double ratingVal = 0.0;
    if (json['rating'] is Map) {
      ratingVal = double.tryParse(json['rating']['ratings']?.toString() ?? '0') ?? 0.0;
    }

    String dFee = json['delivery_charges']?.toString() ?? '0';
    if (dFee.endsWith('.00000')) dFee = dFee.replaceAll('.00000', '');

    final cuisineIdValue = json['cuisine_id']?.toString() ?? '';

    final rawStatus = json['open_status_raw']?.toString() ?? '';
    final displayStatus = json['open_status']?.toString() ?? '';

    debugPrint('📦 [MerchantDto] ساخت فروشگاه: ${json['restaurant_name']}, cuisineId=$cuisineIdValue, rawStatus=$rawStatus');

    return MerchantDto(
      id: json['merchant_id']?.toString() ?? '',
      name: json['restaurant_name']?.toString() ?? 'بدون نام',
      logo: json['logo']?.toString() ?? '',
      background: json['background_url']?.toString() ?? '',
      cuisineText: json['cuisine']?.toString() ?? '',
      distance: json['distance_plot']?.toString() ?? '',
      rating: ratingVal,
      deliveryFee: dFee,
      openStatus: displayStatus,
      openStatusRaw: rawStatus,
      cuisineId: cuisineIdValue,
    );
  }
}