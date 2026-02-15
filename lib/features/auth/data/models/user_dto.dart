import '../../domain/entities/user_entity.dart';

class UserDto extends UserEntity {
  const UserDto({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  }) : super(
          token: token,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // 1. پیدا کردن محل واقعی دیتا (پشتیبانی از client_info برای لاگین)
    dynamic data = json['details'];
    
    if (data != null && data['client_info'] != null) {
      data = data['client_info'];
    }

    return UserDto(
      token: data?['token']?.toString() ?? '',
      firstName: data?['first_name']?.toString() ?? '',
      lastName: data?['last_name']?.toString() ?? '',
      phone: data?['contact_phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'first_name': firstName,
      'last_name': lastName,
      'contact_phone': phone,
    };
  }
}