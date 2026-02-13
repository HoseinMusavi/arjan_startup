import 'package:flutter/foundation.dart';

class CuisineDto {
  final String id;
  final String name;
  final String image;

  CuisineDto({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CuisineDto.fromJson(Map<String, dynamic> json) {
    try {
      return CuisineDto(
        id: json['cuisine_id'].toString(),
        name: json['cuisine_name'] ?? json['name'] ?? 'نامشخص', // پشتیبانی از نام‌های مختلف احتمالی
        image: json['featured_image'] ?? json['image'] ?? '',
      );
    } catch (e) {
      debugPrint("❌ Error parsing CuisineDto: $e");
      rethrow;
    }
  }
}