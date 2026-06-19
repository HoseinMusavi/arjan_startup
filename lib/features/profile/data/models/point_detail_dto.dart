import 'package:equatable/equatable.dart';

/// مدل جزئیات کیف پول (هر رکورد در لیست)
/// منطبق با پاسخ API: /mobileappv2/api/GetPointDetails
class PointDetailDto extends Equatable {
  final String date;
  final String label;
  final String points; // در API به صورت String ارسال می‌شود

  const PointDetailDto({
    required this.date,
    required this.label,
    required this.points,
  });

  /// ساخت نمونه از JSON (هر آیتم داخل لیست details.data)
  factory PointDetailDto.fromJson(Map<String, dynamic> json) {
    return PointDetailDto(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      points: json['points']?.toString() ?? '0',
    );
  }

  @override
  List<Object?> get props => [date, label, points];
}