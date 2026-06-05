import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

enum OrderStatus { initial, loading, success, failure, empty }

class OrderState extends Equatable {
  final OrderStatus status;
  final String currentTab;
  final List<OrderEntity> orders;
  final OrderDetailEntity? orderDetail;
  final String? errorMessage;
  final List<OrderSearchEntity> searchResults;
  final bool isSearching;

  const OrderState({
    this.status = OrderStatus.initial,
    this.currentTab = 'all',
    this.orders = const [],
    this.orderDetail,
    this.errorMessage,
    this.searchResults = const [],
    this.isSearching = false,
  });

  OrderState copyWith({
    OrderStatus? status,
    String? currentTab,
    List<OrderEntity>? orders,
    OrderDetailEntity? orderDetail,
    String? errorMessage,
    List<OrderSearchEntity>? searchResults,
    bool? isSearching,
  }) {
    return OrderState(
      status: status ?? this.status,
      currentTab: currentTab ?? this.currentTab,
      orders: orders ?? this.orders,
      orderDetail: orderDetail ?? this.orderDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    status, currentTab, orders, orderDetail, errorMessage, searchResults, isSearching
  ];
}