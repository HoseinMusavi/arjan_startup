class PreCheckoutResponseDto {
  final bool futureOrder;
  final String futureOrderConfirm;
  final String futureOrderMessage;

  PreCheckoutResponseDto({
    required this.futureOrder,
    required this.futureOrderConfirm,
    required this.futureOrderMessage,
  });

  factory PreCheckoutResponseDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? {};
    return PreCheckoutResponseDto(
      futureOrder: details['future_order'] ?? false,
      futureOrderConfirm: details['future_order_confirm']?.toString() ?? '',
      futureOrderMessage: details['future_order_message']?.toString() ?? '',
    );
  }
}

class PayNowResponseDto {
  final bool success;
  final String orderId;
  final double totalAmount;
  final String redirectUrl;
  final String paymentProvider;
  final String message;

  PayNowResponseDto({
    required this.success,
    required this.orderId,
    required this.totalAmount,
    required this.redirectUrl,
    required this.paymentProvider,
    required this.message,
  });

  factory PayNowResponseDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? {};
    return PayNowResponseDto(
      success: json['code'] == 1,
      orderId: details['order_id']?.toString() ?? '',
      totalAmount: double.tryParse(details['total_amount']?.toString() ?? '0') ?? 0,
      redirectUrl: details['redirect_url']?.toString() ?? '',
      paymentProvider: details['payment_provider']?.toString() ?? '',
      message: json['msg']?.toString() ?? '',
    );
  }
}

class RedeemPointsResponseDto {
  final bool success;
  final String message;

  RedeemPointsResponseDto({
    required this.success,
    required this.message,
  });

  factory RedeemPointsResponseDto.fromJson(Map<String, dynamic> json) {
    return RedeemPointsResponseDto(
      success: json['code'] == 1,
      message: json['msg']?.toString() ?? '',
    );
  }
}