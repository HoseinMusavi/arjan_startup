import '../../domain/entities/user_entity.dart';

class UserDto extends UserEntity {
  UserDto({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.token,
    required super.phone,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // گاهی سرور details را می‌فرستد، گاهی مستقیم فیلدها را
    final data = json['details'] ?? json; 
    
    return UserDto(
      id: (data['client_id'] ?? '').toString(),
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email_address'] ?? '',
      token: data['client_token'] ?? '', // این مهم‌ترین فیلد است
      phone: data['contact_phone'] ?? '',
    );
  }
}