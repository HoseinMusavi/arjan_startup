import 'package:equatable/equatable.dart';

/// Entity سفارش در لایه Domain
class OrderEntity extends Equatable {
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

  const OrderEntity({
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

  @override
  List<Object?> get props => [
    orderId, merchantId, merchantName, logo, paymentType,
    totalWTax, status, statusRaw, dateCreated, dateCreatedRaw,
    transType, addTrack
  ];
}

/// Entity جزییات سفارش
class OrderDetailEntity extends Equatable {
  final List<OrderInfoItemEntity> infoItems;
  final String htmlContent;
  final String subtotal;
  final String deliveryCharges;
  final String total;

  const OrderDetailEntity({
    required this.infoItems,
    required this.htmlContent,
    required this.subtotal,
    required this.deliveryCharges,
    required this.total,
  });

  @override
  List<Object?> get props => [infoItems, htmlContent, subtotal, deliveryCharges, total];
}

/// Entity آیتم اطلاعات سفارش
class OrderInfoItemEntity extends Equatable {
  final String label;
  final String value;

  const OrderInfoItemEntity({
    required this.label,
    required this.value,
  });

  @override
  List<Object?> get props => [label, value];
}

/// Entity نتیجه ثبت مجدد سفارش
class ReOrderEntity extends Equatable {
  final String merchantId;

  const ReOrderEntity({required this.merchantId});

  @override
  List<Object?> get props => [merchantId];
}

/// Entity نتیجه پیگیری سفارش
class TrackEntity extends Equatable {
  final bool runTrack;

  const TrackEntity({required this.runTrack});

  @override
  List<Object?> get props => [runTrack];
}

/// Entity نتیجه جستجوی سفارش
class OrderSearchEntity extends Equatable {
  final String orderId;
  final String restaurantName;
  final String logo;
  final String totalWTax;
  final String paymentType;
  final String transaction;

  const OrderSearchEntity({
    required this.orderId,
    required this.restaurantName,
    required this.logo,
    required this.totalWTax,
    required this.paymentType,
    required this.transaction,
  });

  @override
  List<Object?> get props => [
    orderId, restaurantName, logo, totalWTax, paymentType, transaction
  ];
}