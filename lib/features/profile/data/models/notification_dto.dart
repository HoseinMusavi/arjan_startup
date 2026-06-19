import 'package:equatable/equatable.dart';

/// مدل اعلان‌ها (پیام‌های دریافتی)
/// منطبق با پاسخ API: /mobileappv2/api/GetNotifications
class NotificationDto extends Equatable {
  final String id;
  final String pushTitle;
  final String pushMessage;
  final String dateCreated;

  const NotificationDto({
    required this.id,
    required this.pushTitle,
    required this.pushMessage,
    required this.dateCreated,
  });

  /// ساخت نمونه از JSON (هر آیتم داخل لیست details.data)
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id']?.toString() ?? '',
      pushTitle: json['push_title']?.toString() ?? '',
      pushMessage: json['push_message']?.toString() ?? '',
      dateCreated: json['date_created']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, pushTitle, pushMessage, dateCreated];
}