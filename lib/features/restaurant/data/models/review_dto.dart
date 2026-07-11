import 'package:equatable/equatable.dart';

class ReviewListResponseDto extends Equatable {
  final int code;
  final String msg;
  final List<ReviewDto> reviews;

  const ReviewListResponseDto({
    required this.code,
    required this.msg,
    required this.reviews,
  });

  factory ReviewListResponseDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final List<dynamic> list = details?['list'] as List? ?? [];
    return ReviewListResponseDto(
      code: json['code'] as int? ?? 0,
      msg: json['msg']?.toString() ?? '',
      reviews: list.map((e) => ReviewDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool get isSuccess => code == 1 || code == 6;
  bool get isEmpty => code == 6 || reviews.isEmpty;

  @override
  List<Object?> get props => [code, msg, reviews];
}

class ReviewDto extends Equatable {
  final String id;
  final String clientName;
  final String rating;
  final String comment;
  final String dateCreated;
  final String avatar;

  const ReviewDto({
    required this.id,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.dateCreated,
    required this.avatar,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['review_id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? 'کاربر ناشناس',
      rating: json['rating']?.toString() ?? '0',
      comment: json['comment']?.toString() ?? '',
      dateCreated: json['date_created']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  double get ratingValue => double.tryParse(rating) ?? 0;

  @override
  List<Object?> get props => [id, clientName, rating, comment, dateCreated, avatar];
}