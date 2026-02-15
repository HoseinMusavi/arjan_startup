class UserProfileDto {
  final String firstName;
  final String lastName;
  final int points;
  final String avatar;

  UserProfileDto({
    required this.firstName,
    required this.lastName,
    required this.points,
    required this.avatar,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    // استخراج امن داده‌ها از json['details']['data']
    final data = json['details'] != null && json['details']['data'] != null 
        ? json['details']['data'] 
        : {};
        
    return UserProfileDto(
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      // تبدیل ایمن امتیاز که ممکن است String یا Int باشد
      points: int.tryParse(data['points']?.toString() ?? '0') ?? 0,
      avatar: data['avatar'] ?? '',
    );
  }
}