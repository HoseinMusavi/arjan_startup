import 'package:equatable/equatable.dart';

class RestaurantInfoDto extends Equatable {
  final String id;
  final String name;
  final String address;
  final String cuisine;
  final String logo;
  final String backgroundUrl;
  final String status;
  final String statusRaw;
  final double rating;
  final bool addedAsFavorite;

  const RestaurantInfoDto({
    required this.id,
    required this.name,
    required this.address,
    required this.cuisine,
    required this.logo,
    required this.backgroundUrl,
    required this.status,
    required this.statusRaw,
    required this.rating,
    required this.addedAsFavorite,
  });

  factory RestaurantInfoDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final ratingData = data['rating'] as Map<String, dynamic>?;
    double ratingVal = 0.0;
    if (ratingData != null) {
      final ratings = ratingData['ratings'];
      if (ratings is num) {
        ratingVal = ratings.toDouble();
      } else if (ratings is String) {
        ratingVal = double.tryParse(ratings) ?? 0.0;
      }
    }
    return RestaurantInfoDto(
      id: data['merchant_id']?.toString() ?? '',
      name: data['restaurant_name']?.toString() ?? '',
      address: data['complete_address']?.toString() ?? '',
      cuisine: data['cuisine']?.toString() ?? '',
      logo: data['logo']?.toString() ?? '',
      backgroundUrl: data['background_url']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      statusRaw: data['status_raw']?.toString() ?? '',
      rating: ratingVal,
      addedAsFavorite: data['added_as_favorite'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    cuisine,
    logo,
    backgroundUrl,
    status,
    statusRaw,
    rating,
    addedAsFavorite,
  ];
}