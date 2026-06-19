import 'package:equatable/equatable.dart';

/// مدل داده‌ای پروفایل کاربر
/// منطبق با پاسخ API: /mobileappv2/api/GetProfile
class ProfileDto extends Equatable {
  final String avatar;
  final String firstName;
  final String lastName;
  final String fullName;
  final String emailAddress;
  final String contactPhone;

  const ProfileDto({
    required this.avatar,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.emailAddress,
    required this.contactPhone,
  });

  /// ساخت نمونه از JSON پاسخ سرور
  /// ساختار پاسخ: { "details": { "data": { ... } } }
  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final data = details['data'] as Map<String, dynamic>? ?? {};

    return ProfileDto(
      avatar: data['avatar']?.toString() ?? '',
      firstName: data['first_name']?.toString() ?? '',
      lastName: data['last_name']?.toString() ?? '',
      fullName: data['full_name']?.toString() ?? '',
      emailAddress: data['email_address']?.toString() ?? '',
      contactPhone: data['contact_phone']?.toString() ?? '',
    );
  }

  /// تبدیل به JSON (برای ارسال به سرور در ویرایش)
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'contact_phone': contactPhone,
      'email_address': emailAddress,
    };
  }

  @override
  List<Object?> get props => [
        avatar,
        firstName,
        lastName,
        fullName,
        emailAddress,
        contactPhone,
      ];
}