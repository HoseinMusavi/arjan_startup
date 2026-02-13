import 'package:flutter/foundation.dart';

class MerchantDto {
  final String id;
  final String name;
  final String logo;
  final String address;
  final double rating;
  final String deliveryFee;
  final String minOrder;
  final bool isOpen;

  MerchantDto({
    required this.id,
    required this.name,
    required this.logo,
    required this.address,
    required this.rating,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
  });

  factory MerchantDto.fromJson(Map<String, dynamic> json) {
    try {
      return MerchantDto(
        id: json['merchant_id'].toString(),
        name: json['restaurant_name'] ?? 'رستوران',
        logo: json['logo'] ?? '',
        address: json['address'] ?? '',
        rating: double.tryParse(json['ratings']?.toString() ?? '0') ?? 0.0,
        deliveryFee: json['delivery_fees'] ?? '0',
        minOrder: json['minimum_order'] ?? '0',
        isOpen: json['is_open'] == true || json['open_status'] == 'open', // چک کردن وضعیت باز بودن
      );
    } catch (e) {
      debugPrint("❌ Error parsing MerchantDto ID: ${json['merchant_id']}");
      debugPrint("❌ Error Details: $e");
      rethrow;
    }
  }
}