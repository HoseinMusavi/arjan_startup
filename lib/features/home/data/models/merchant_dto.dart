import 'package:flutter/foundation.dart';

class MerchantDto {
  final String id;
  final String name;
  final String logo;
  final String background; // ✅ اضافه شد برای کاور رستوران
  final String address;
  final String distance;
  final double rating;
  final String deliveryFee;
  final String minOrder;
  final bool isOpen;
  final String cuisineText; // ✅ اضافه شد برای نوع غذای رستوران

  MerchantDto({
    required this.id,
    required this.name,
    required this.logo,
    required this.background,
    required this.address,
    required this.distance,
    required this.rating,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
    required this.cuisineText,
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

      // اصلاح و زیباسازی قیمت ارسال (حذف صفرهای اعشاری اضافه)
      String dFee = json['delivery_charges']?.toString() ?? '0';
      if (dFee.endsWith('.00000')) {
        dFee = dFee.replaceAll('.00000', '');
      }

      // مدیریت آدرس عکس‌ها
      String logoUrl = json['logo']?.toString() ?? '';
      if (logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
        logoUrl = 'https://arjanapp.ir/upload/$logoUrl';
      }

      String bgUrl = json['background_url']?.toString() ?? '';
      if (bgUrl.isNotEmpty && !bgUrl.startsWith('http')) {
        bgUrl = 'https://arjanapp.ir/upload/$bgUrl';
      }

      return MerchantDto(
        id: json['merchant_id']?.toString() ?? '',
        name: json['restaurant_name']?.toString() ?? 'بدون نام',
        logo: logoUrl,
        background: bgUrl,
        address: json['address']?.toString() ?? '',
        distance: json['distance_plot']?.toString() ?? '',
        rating: ratingVal,
        deliveryFee: dFee,
        minOrder: json['minimum_order']?.toString() ?? '0',
        isOpen: open,
        cuisineText: json['cuisine']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint("❌ Error parsing MerchantDto: $e");
      return MerchantDto(
        id: '0', 
        name: 'خطا در لود', 
        logo: '', 
        background: '',
        address: '', 
        distance: '', 
        rating: 0, 
        deliveryFee: '0', 
        minOrder: '0', 
        isOpen: false,
        cuisineText: ''
      );
    }
  }
}