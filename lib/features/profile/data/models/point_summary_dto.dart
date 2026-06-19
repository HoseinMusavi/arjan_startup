import 'package:equatable/equatable.dart';

/// مدل خلاصه کیف پول (هر آیتم در لیست)
/// منطبق با پاسخ API: /mobileappv2/api/GetPointSummary
class PointSummaryDto extends Equatable {
  final String label;
  final int value;
  final String pointType; // income_points, expenses_points, expired_points, points_merchant

  const PointSummaryDto({
    required this.label,
    required this.value,
    required this.pointType,
  });

  /// ساخت نمونه از JSON (هر آیتم داخل لیست details.data)
  factory PointSummaryDto.fromJson(Map<String, dynamic> json) {
    return PointSummaryDto(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value']?.toString() ?? '0') ?? 0,
      pointType: json['point_type']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [label, value, pointType];
}