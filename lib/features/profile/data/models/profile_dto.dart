import 'package:equatable/equatable.dart';

class ProfileDto extends Equatable {
  final String firstName;
  final String lastName;
  final int points;
  final String avatar;
  final String phone; // ✅ اضافه شد

  const ProfileDto({
    required this.firstName,
    required this.lastName,
    required this.points,
    required this.avatar,
    required this.phone,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    // مسیر دیتا در لاگ شما: details -> data
    final details = json['details'] ?? {};
    final data = details['data'] ?? {};
    
    return ProfileDto(
      firstName: data['first_name']?.toString() ?? '',
      lastName: data['last_name']?.toString() ?? '',
      points: int.tryParse(data['points']?.toString() ?? '0') ?? 0,
      avatar: data['avatar']?.toString() ?? '',
      phone: data['contact_phone']?.toString() ?? '', // ✅ دریافت شماره تماس
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, points, avatar, phone];
}