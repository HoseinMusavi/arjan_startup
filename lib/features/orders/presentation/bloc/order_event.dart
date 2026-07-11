import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

// ==================== رویدادهای لیست سفارشات ====================

/// بارگذاری لیست سفارشات
class LoadOrdersEvent extends OrderEvent {
  final String tab;
  final double lat;
  final double lng;

  const LoadOrdersEvent({
    required this.tab,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [tab, lat, lng];
}

/// تغییر تب
class ChangeOrderTabEvent extends OrderEvent {
  final String tab;
  final double lat;
  final double lng;

  const ChangeOrderTabEvent({
    required this.tab,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [tab, lat, lng];
}

/// رفرش لیست سفارشات
class RefreshOrdersEvent extends OrderEvent {
  final double lat;
  final double lng;

  const RefreshOrdersEvent({required this.lat, required this.lng});

  @override
  List<Object> get props => [lat, lng];
}

// ==================== رویدادهای جزییات سفارش ====================

/// بارگذاری جزییات سفارش
class LoadOrderDetailEvent extends OrderEvent {
  final String orderId;
  final double lat;
  final double lng;

  const LoadOrderDetailEvent({
    required this.orderId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [orderId, lat, lng];
}

// ==================== رویدادهای ثبت مجدد سفارش ====================

/// ثبت مجدد سفارش
class ReOrderEvent extends OrderEvent {
  final String orderId;
  final double lat;
  final double lng;

  const ReOrderEvent({
    required this.orderId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [orderId, lat, lng];
}

// ==================== رویدادهای پیگیری سفارش ====================

/// بررسی پیگیری سفارش
class CheckTrackEvent extends OrderEvent {
  final String orderId;
  final double lat;
  final double lng;

  const CheckTrackEvent({
    required this.orderId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [orderId, lat, lng];
}

// ==================== رویدادهای جستجوی سفارش ====================

/// جستجوی سفارش
class SearchOrderEvent extends OrderEvent {
  final String searchStr;
  final double lat;
  final double lng;

  const SearchOrderEvent({
    required this.searchStr,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [searchStr, lat, lng];
}

/// پاک کردن نتایج جستجو
class ClearSearchEvent extends OrderEvent {}