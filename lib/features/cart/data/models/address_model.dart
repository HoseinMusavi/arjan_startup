class AddressDto {
  final String id;
  final String address;
  final String locationName;
  final String countryCode;
  final bool isDefault;

  AddressDto({
    required this.id,
    required this.address,
    required this.locationName,
    required this.countryCode,
    required this.isDefault,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      isDefault: json['as_default'] == '1' || json['as_default'] == 1,
    );
  }
}

class AddressResponseDto {
  final String completeAddress;
  final String formattedAddress;
  final String street;
  final String city;
  final String state;
  final String zipcode;
  final String country;
  final double minDeliveryOrder;

  AddressResponseDto({
    required this.completeAddress,
    required this.formattedAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.country,
    required this.minDeliveryOrder,
  });

  factory AddressResponseDto.fromJson(Map<String, dynamic> json) {
    return AddressResponseDto(
      completeAddress: json['complete_address']?.toString() ?? '',
      formattedAddress: json['formatted_address']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipcode: json['zipcode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      minDeliveryOrder: double.tryParse(json['min_delivery_order']?.toString() ?? '0') ?? 0,
    );
  }
}