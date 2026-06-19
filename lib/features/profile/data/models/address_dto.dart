import 'package:equatable/equatable.dart';

/// مدل آدرس دفترچه آدرس
/// منطبق با پاسخ API: /mobileappv2/api/AddressBookList
class AddressDto extends Equatable {
  final String id;
  final String asDefault; // '1' = پیش‌فرض, '2' = غیرپیش‌فرض
  final String address;
  final String dateCreated;
  final String dateAdded;

  const AddressDto({
    required this.id,
    required this.asDefault,
    required this.address,
    required this.dateCreated,
    required this.dateAdded,
  });

  /// ساخت نمونه از JSON (هر آیتم داخل لیست details.data)
  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id']?.toString() ?? '',
      asDefault: json['as_default']?.toString() ?? '2',
      address: json['address']?.toString() ?? '',
      dateCreated: json['date_created']?.toString() ?? '',
      dateAdded: json['date_added']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, asDefault, address, dateCreated, dateAdded];
}