import 'package:flutter/foundation.dart';

class MerchantDto {
  final String id;
  final String name;
  final String logo;
  final String address;
  final String distance;
  final double rating;
  final String deliveryFee;
  final String minOrder;
  final bool isOpen;

  MerchantDto({
    required this.id,
    required this.name,
    required this.logo,
    required this.address,
    required this.distance,
    required this.rating,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
  });

  factory MerchantDto.fromJson(Map<String, dynamic> json) {
    try {
      // استخراج امتیاز از آبجکت rating
      double ratingVal = 0.0;
      if (json['rating'] is Map) {
        ratingVal = double.tryParse(json['rating']['ratings']?.toString() ?? '0') ?? 0.0;
      } else {
        ratingVal = double.tryParse(json['ratings']?.toString() ?? '0') ?? 0.0;
      }

      // وضعیت باز بودن
      bool open = false;
      final statusRaw = json['open_status_raw']?.toString();
      if (statusRaw == 'open' || statusRaw == 'open_for_delivery') {
        open = true;
      }

      return MerchantDto(
        id: json['merchant_id']?.toString() ?? '',
        name: json['restaurant_name']?.toString() ?? 'رستوران',
        logo: json['logo']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        distance: json['distance_plot']?.toString() ?? '',
        rating: ratingVal,
        deliveryFee: json['delivery_charges']?.toString() ?? '0',
        minOrder: json['minimum_order']?.toString() ?? '0',
        isOpen: open,
      );
    } catch (e) {
      debugPrint("❌ Error parsing MerchantDto: $e");
      return MerchantDto(
        id: '0', name: 'Error', logo: '', address: '', distance: '', 
        rating: 0, deliveryFee: '', minOrder: '', isOpen: false
      );
    }
  }
}