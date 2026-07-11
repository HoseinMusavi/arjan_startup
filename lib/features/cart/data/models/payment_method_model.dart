class PaymentMethodDto {
  final String paymentCode;
  final String paymentName;

  PaymentMethodDto({
    required this.paymentCode,
    required this.paymentName,
  });

  factory PaymentMethodDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDto(
      paymentCode: json['payment_code']?.toString() ?? '',
      paymentName: json['payment_name']?.toString() ?? '',
    );
  }
}