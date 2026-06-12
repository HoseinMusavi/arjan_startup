import 'package:flutter/foundation.dart';

class SearchItemDto {
  final String id;              // id محصول
  final String title;           // عنوان (با تگ highlight)
  final String subTitle;        // توضیحات (می‌تواند HTML باشد)
  final String logo;            // آدرس لوگو
  final String merchantId;      // آیدی فروشگاه
  final String category;        // دسته‌بندی
  final String mmtid;           // معادل merchant_id تکراری
  final String restaurant;      // نوع (مثلاً food)
  final String deliveryFee;     // هزینه ارسال (خالی یا عدد)

  SearchItemDto({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.logo,
    required this.merchantId,
    required this.category,
    required this.mmtid,
    required this.restaurant,
    required this.deliveryFee,
  });

  factory SearchItemDto.fromJson(Map<String, dynamic> json) {
    return SearchItemDto(
      id: json['id']?.toString() ?? '',
      title: _cleanHtmlTags(json['title']?.toString() ?? ''),
      subTitle: _cleanHtmlTags(json['sub_title']?.toString() ?? ''),
      logo: json['logo']?.toString() ?? '',
      merchantId: json['merchant_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      mmtid: json['mmtid']?.toString() ?? '',
      restaurant: json['restaurant']?.toString() ?? '',
      deliveryFee: json['delivery_fee']?.toString() ?? '0',
    );
  }

  // حذف تگ‌های HTML از متن (مانند <span class="highlight">)
  static String _cleanHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true);
    return htmlText.replaceAll(exp, '').trim();
  }
}