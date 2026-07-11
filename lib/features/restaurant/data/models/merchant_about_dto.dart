import 'package:equatable/equatable.dart';

class MerchantAboutDto extends Equatable {
  final int code;
  final String msg;
  final MerchantAboutDataDto data;

  const MerchantAboutDto({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory MerchantAboutDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final dataMap = details?['data'] as Map<String, dynamic>? ?? {};
    return MerchantAboutDto(
      code: json['code'] as int? ?? 0,
      msg: json['msg']?.toString() ?? '',
      data: MerchantAboutDataDto.fromJson(dataMap),
    );
  }

  bool get isSuccess => code == 1;

  @override
  List<Object?> get props => [code, msg, data];
}

class MerchantAboutDataDto extends Equatable {
  final String merchantId;
  final String restaurantName;
  final String completeAddress;
  final String restaurantPhone;
  final String contactPhone;
  final String latitude;
  final String longitude;
  final String merchantTableBooking;
  final String cuisine;
  final RatingDto rating;
  final String reviewCount;
  final List<OpeningDto> opening;
  final List<PaymentDto> payment;
  final String information;
  final String website;
  final String services;

  const MerchantAboutDataDto({
    required this.merchantId,
    required this.restaurantName,
    required this.completeAddress,
    required this.restaurantPhone,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
    required this.merchantTableBooking,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.opening,
    required this.payment,
    required this.information,
    required this.website,
    required this.services,
  });

  factory MerchantAboutDataDto.fromJson(Map<String, dynamic> json) {
    return MerchantAboutDataDto(
      merchantId: json['merchant_id']?.toString() ?? '',
      restaurantName: json['restaurant_name']?.toString() ?? '',
      completeAddress: json['complete_address']?.toString() ?? '',
      restaurantPhone: json['restaurant_phone']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['lontitude']?.toString() ?? '',
      merchantTableBooking: json['merchant_table_booking']?.toString() ?? '',
      cuisine: json['cuisine']?.toString() ?? '',
      rating: RatingDto.fromJson(json['rating'] as Map<String, dynamic>? ?? {}),
      reviewCount: json['review_count']?.toString() ?? '0 نظر',
      opening: (json['opening'] as List? ?? [])
          .map((e) => OpeningDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      payment: (json['payment'] as List? ?? [])
          .map((e) => PaymentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      information: _cleanHtml(json['information']?.toString() ?? ''),
      website: json['website']?.toString() ?? '',
      services: json['services']?.toString() ?? '',
    );
  }

  // حذف تگ‌های HTML و &nbsp;
  static String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    // حذف تگ‌های HTML
    String cleaned = html.replaceAll(RegExp(r'<[^>]*>'), '');
    // جایگزینی &nbsp; با فاصله
    cleaned = cleaned.replaceAll('&nbsp;', ' ');
    // حذف فاصله‌های اضافی
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  @override
  List<Object?> get props => [
        merchantId,
        restaurantName,
        completeAddress,
        restaurantPhone,
        contactPhone,
        latitude,
        longitude,
        merchantTableBooking,
        cuisine,
        rating,
        reviewCount,
        opening,
        payment,
        information,
        website,
        services,
      ];
}

class RatingDto extends Equatable {
  final int ratings;
  final int votes;

  const RatingDto({
    required this.ratings,
    required this.votes,
  });

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    return RatingDto(
      ratings: json['ratings'] as int? ?? 0,
      votes: json['votes'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [ratings, votes];
}

class OpeningDto extends Equatable {
  final String day;
  final String hours;
  final String openText;

  const OpeningDto({
    required this.day,
    required this.hours,
    required this.openText,
  });

  factory OpeningDto.fromJson(Map<String, dynamic> json) {
    return OpeningDto(
      day: json['day']?.toString() ?? '',
      hours: json['hours']?.toString() ?? '',
      openText: json['open_text']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [day, hours, openText];
}

class PaymentDto extends Equatable {
  final String label;

  const PaymentDto({
    required this.label,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      label: json['label']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [label];
}