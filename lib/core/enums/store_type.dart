import 'package:flutter/material.dart';

enum StoreType {
  restaurant,
  supermarket,
  locations,
  profile,
}

extension StoreTypeExtension on StoreType {
  Color get primaryColor {
    switch (this) {
      case StoreType.restaurant:
        return const Color(0xFFFF7A00);
      case StoreType.supermarket:
        return const Color(0xFF2E7D32);
      case StoreType.locations:
        return const Color(0xFF2196F3);
      case StoreType.profile:
        return const Color(0xFF9C27B0);
    }
  }

  String? get cuisineId {
    switch (this) {
      case StoreType.supermarket:
        return '59';
      default:
        return null;
    }
  }

  String get apiSearchType {
    switch (this) {
      case StoreType.supermarket:
        return 'byCuisine';
      default:
        return 'byLatLong';
    }
  }
  
  String get title {
    switch (this) {
      case StoreType.restaurant:
        return 'رستوران';
      case StoreType.supermarket:
        return 'سوپرمارکت';
      case StoreType.locations:
        return 'مکان‌ها';
      case StoreType.profile:
        return 'پروفایل';
    }
  }

  IconData get iconOutline {
    switch (this) {
      case StoreType.restaurant:
        return Icons.restaurant_outlined;
      case StoreType.supermarket:
        return Icons.store_outlined;
      case StoreType.locations:
        return Icons.location_on_outlined;
      case StoreType.profile:
        return Icons.person_outline_rounded;
    }
  }

  IconData get iconFilled {
    switch (this) {
      case StoreType.restaurant:
        return Icons.restaurant_rounded;
      case StoreType.supermarket:
        return Icons.store_rounded;
      case StoreType.locations:
        return Icons.location_on_rounded;
      case StoreType.profile:
        return Icons.person_rounded;
    }
  }
}