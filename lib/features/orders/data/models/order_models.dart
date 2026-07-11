import 'package:equatable/equatable.dart';


import 'package:flutter/material.dart';
// مدل پاسخ لیست سفارشات
class OrderListResponseDto extends Equatable {
  final int code;
  final String message;
  final OrderListDetailsDto? details;

  const OrderListResponseDto({
    required this.code,
    required this.message,
    this.details,
  });

  factory OrderListResponseDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [OrderListResponseDto] تبدیل JSON به مدل');
    return OrderListResponseDto(
      code: json['code'] ?? 0,
      message: json['msg']?.toString() ?? '',
      details: json['details'] != null
          ? OrderListDetailsDto.fromJson(json['details'])
          : null,
    );
  }

  @override
  List<Object?> get props => [code, message, details];
}

// مدل جزئیات لیست سفارشات
class OrderListDetailsDto extends Equatable {
  final List<OrderItemDto> orders;
  final int paginateTotal;

  const OrderListDetailsDto({
    required this.orders,
    required this.paginateTotal,
  });

  factory OrderListDetailsDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [OrderListDetailsDto] تبدیل JSON به مدل');
    final List<dynamic> list = json['data'] ?? [];
    return OrderListDetailsDto(
      orders: list.map((e) => OrderItemDto.fromJson(e)).toList(),
      paginateTotal: json['paginate_total'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [orders, paginateTotal];
}

// مدل آیتم سفارش
class OrderItemDto extends Equatable {
  final String orderId;
  final String merchantId;
  final String merchantName;
  final String logo;
  final String paymentType;
  final String totalWTax;
  final String status;
  final String statusRaw;
  final String dateCreated;
  final String dateCreatedRaw;
  final String transType;
  final bool addTrack;

  const OrderItemDto({
    required this.orderId,
    required this.merchantId,
    required this.merchantName,
    required this.logo,
    required this.paymentType,
    required this.totalWTax,
    required this.status,
    required this.statusRaw,
    required this.dateCreated,
    required this.dateCreatedRaw,
    required this.transType,
    required this.addTrack,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [OrderItemDto] تبدیل JSON به مدل برای سفارش: ${json['order_id']}');
    return OrderItemDto(
      orderId: json['order_id']?.toString() ?? '',
      merchantId: json['merchant_id']?.toString() ?? '',
      merchantName: json['merchant_name']?.toString() ?? 'نامشخص',
      logo: json['logo']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      totalWTax: json['total_w_tax']?.toString() ?? '0 تومان',
      status: json['status']?.toString() ?? '',
      statusRaw: json['status_raw']?.toString() ?? '',
      dateCreated: json['date_created']?.toString() ?? '',
      dateCreatedRaw: json['date_created_raw']?.toString() ?? '',
      transType: json['trans_type']?.toString() ?? 'delivery',
      addTrack: json['add_track'] == true,
    );
  }

  @override
  List<Object?> get props => [
    orderId, merchantId, merchantName, logo, paymentType,
    totalWTax, status, statusRaw, dateCreated, dateCreatedRaw, transType, addTrack
  ];
}

// مدل جزییات سفارش (ViewOrder)
class OrderDetailResponseDto extends Equatable {
  final int code;
  final String message;
  final OrderDetailDto? details;

  const OrderDetailResponseDto({
    required this.code,
    required this.message,
    this.details,
  });

  factory OrderDetailResponseDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [OrderDetailResponseDto] تبدیل JSON به مدل');
    return OrderDetailResponseDto(
      code: json['code'] ?? 0,
      message: json['msg']?.toString() ?? '',
      details: json['details'] != null
          ? OrderDetailDto.fromJson(json['details'])
          : null,
    );
  }

  @override
  List<Object?> get props => [code, message, details];
}

// مدل جزییات سفارش
class OrderDetailDto extends Equatable {
  final List<OrderInfoItemDto> infoItems;
  final String htmlContent;
  final String subtotal;
  final String deliveryCharges;
  final String total;

  const OrderDetailDto({
    required this.infoItems,
    required this.htmlContent,
    required this.subtotal,
    required this.deliveryCharges,
    required this.total,
  });

  factory OrderDetailDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [OrderDetailDto] تبدیل JSON به مدل');
    final List<dynamic> dataList = json['data'] ?? [];
    return OrderDetailDto(
      infoItems: dataList.map((e) => OrderInfoItemDto.fromJson(e)).toList(),
      htmlContent: json['html']?.toString() ?? '',
      subtotal: _extractSubtotalFromHtml(json['html']?.toString() ?? ''),
      deliveryCharges: _extractDeliveryFromHtml(json['html']?.toString() ?? ''),
      total: _extractTotalFromHtml(json['html']?.toString() ?? ''),
    );
  }

  static String _extractSubtotalFromHtml(String html) {
    final match = RegExp(r'cart_subtotal["\s]*>([^<]+)').firstMatch(html);
    return match?.group(1)?.trim() ?? '0 تومان';
  }

  static String _extractDeliveryFromHtml(String html) {
    final match = RegExp(r'هزینه ارسال<\/div>[^<]*<div[^>]*>([^<]+)').firstMatch(html);
    return match?.group(1)?.trim() ?? '0 تومان';
  }

  static String _extractTotalFromHtml(String html) {
    final match = RegExp(r'cart_total["\s]*>([^<]+)').firstMatch(html);
    return match?.group(1)?.trim() ?? '0 تومان';
  }

  @override
  List<Object?> get props => [infoItems, htmlContent, subtotal, deliveryCharges, total];
}

// مدل آیتم اطلاعات (لیبل/مقدار)
class OrderInfoItemDto extends Equatable {
  final String label;
  final String value;

  const OrderInfoItemDto({
    required this.label,
    required this.value,
  });

  factory OrderInfoItemDto.fromJson(Map<String, dynamic> json) {
    return OrderInfoItemDto(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [label, value];
}

// مدل پاسخ ReOrder
class ReOrderResponseDto extends Equatable {
  final int code;
  final String message;
  final String merchantId;

  const ReOrderResponseDto({
    required this.code,
    required this.message,
    required this.merchantId,
  });

  factory ReOrderResponseDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [ReOrderResponseDto] تبدیل JSON به مدل');
    return ReOrderResponseDto(
      code: json['code'] ?? 0,
      message: json['msg']?.toString() ?? '',
      merchantId: json['details']?['merchant_id']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [code, message, merchantId];
}

// مدل پاسخ Track
class TrackResponseDto extends Equatable {
  final int code;
  final String message;
  final bool runTrack;

  const TrackResponseDto({
    required this.code,
    required this.message,
    required this.runTrack,
  });

  factory TrackResponseDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [TrackResponseDto] تبدیل JSON به مدل');
    return TrackResponseDto(
      code: json['code'] ?? 0,
      message: json['msg']?.toString() ?? '',
      runTrack: json['details']?['run_track'] == true,
    );
  }

  @override
  List<Object?> get props => [code, message, runTrack];
}

// مدل جستجوی سفارش
class OrderSearchResponseDto extends Equatable {
  final int code;
  final String message;
  final List<OrderSearchItemDto> items;

  const OrderSearchResponseDto({
    required this.code,
    required this.message,
    required this.items,
  });

  factory OrderSearchResponseDto.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 [OrderSearchResponseDto] تبدیل JSON به مدل');
    final List<dynamic> list = json['details']?['list'] ?? [];
    return OrderSearchResponseDto(
      code: json['code'] ?? 0,
      message: json['msg']?.toString() ?? '',
      items: list.map((e) => OrderSearchItemDto.fromJson(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [code, message, items];
}

// مدل آیتم جستجو
class OrderSearchItemDto extends Equatable {
  final String orderId;
  final String restaurantName;
  final String logo;
  final String totalWTax;
  final String paymentType;
  final String transaction;

  const OrderSearchItemDto({
    required this.orderId,
    required this.restaurantName,
    required this.logo,
    required this.totalWTax,
    required this.paymentType,
    required this.transaction,
  });

  factory OrderSearchItemDto.fromJson(Map<String, dynamic> json) {
    return OrderSearchItemDto(
      orderId: json['order_id']?.toString() ?? '',
      restaurantName: json['restaurant_name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      totalWTax: json['total_w_tax']?.toString() ?? '0 تومان',
      paymentType: json['payment_type']?.toString() ?? '',
      transaction: json['transaction']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [orderId, restaurantName, logo, totalWTax, paymentType, transaction];
}