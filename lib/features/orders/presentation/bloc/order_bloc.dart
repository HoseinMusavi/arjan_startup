import 'package:arjan_startup/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/features/orders/domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

export 'order_event.dart';
export 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc(this._repository) : super(const OrderState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<ChangeOrderTabEvent>(_onChangeTab);
    on<RefreshOrdersEvent>(_onRefreshOrders);
    on<LoadOrderDetailEvent>(_onLoadOrderDetail);
    on<ReOrderEvent>(_onReOrder);
    on<CheckTrackEvent>(_onCheckTrack);
    on<SearchOrderEvent>(_onSearchOrder);
    on<ClearSearchEvent>(_onClearSearch);
  }

  // ==================== بارگذاری لیست سفارشات ====================
  Future<void> _onLoadOrders(LoadOrdersEvent event, Emitter<OrderState> emit) async {
    debugPrint('📋 [OrderBloc] بارگذاری سفارشات - tab: ${event.tab}');
    emit(state.copyWith(status: OrderStatus.loading, currentTab: event.tab));

    final result = await _repository.getOrderList(event.tab, event.lat, event.lng);

    result.fold(
      (failure) {
        debugPrint('❌ [OrderBloc] خطا: ${failure.message}');
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (response) {
        if (response.code == 1 && response.details != null) {
          final orders = response.details!.orders;
          debugPrint('✅ [OrderBloc] ${orders.length} سفارش دریافت شد');
          
          if (orders.isEmpty) {
            emit(state.copyWith(status: OrderStatus.empty, orders: []));
          } else {
            final entities = orders.map((dto) => OrderEntity(
              orderId: dto.orderId,
              merchantId: dto.merchantId,
              merchantName: dto.merchantName,
              logo: dto.logo,
              paymentType: dto.paymentType,
              totalWTax: dto.totalWTax,
              status: dto.status,
              statusRaw: dto.statusRaw,
              dateCreated: dto.dateCreated,
              dateCreatedRaw: dto.dateCreatedRaw,
              transType: dto.transType,
              addTrack: dto.addTrack,
            )).toList();
            emit(state.copyWith(status: OrderStatus.success, orders: entities));
          }
        } else {
          debugPrint('⚠️ [OrderBloc] پاسخ با خطا: ${response.message}');
          emit(state.copyWith(status: OrderStatus.empty, orders: []));
        }
      },
    );
  }

  // ==================== تغییر تب ====================
  Future<void> _onChangeTab(ChangeOrderTabEvent event, Emitter<OrderState> emit) async {
    debugPrint('📋 [OrderBloc] تغییر تب به: ${event.tab}');
    add(LoadOrdersEvent(tab: event.tab, lat: event.lat, lng: event.lng));
  }

  // ==================== رفرش لیست ====================
  Future<void> _onRefreshOrders(RefreshOrdersEvent event, Emitter<OrderState> emit) async {
    debugPrint('📋 [OrderBloc] رفرش سفارشات');
    add(LoadOrdersEvent(tab: state.currentTab, lat: event.lat, lng: event.lng));
  }

  // ==================== بارگذاری جزییات سفارش ====================
  Future<void> _onLoadOrderDetail(LoadOrderDetailEvent event, Emitter<OrderState> emit) async {
    debugPrint('📋 [OrderBloc] دریافت جزییات سفارش - orderId: ${event.orderId}');
    emit(state.copyWith(status: OrderStatus.loading));

    final result = await _repository.getOrderDetail(event.orderId, event.lat, event.lng);

    result.fold(
      (failure) {
        debugPrint('❌ [OrderBloc] خطا: ${failure.message}');
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (response) {
        if (response.code == 1 && response.details != null) {
          final detail = response.details!;
          final entity = OrderDetailEntity(
            infoItems: detail.infoItems.map((item) => OrderInfoItemEntity(
              label: item.label,
              value: item.value,
            )).toList(),
            htmlContent: detail.htmlContent,
            subtotal: detail.subtotal,
            deliveryCharges: detail.deliveryCharges,
            total: detail.total,
          );
          debugPrint('✅ [OrderBloc] جزییات سفارش دریافت شد');
          emit(state.copyWith(status: OrderStatus.success, orderDetail: entity));
        } else {
          debugPrint('⚠️ [OrderBloc] پاسخ با خطا: ${response.message}');
          emit(state.copyWith(status: OrderStatus.failure, errorMessage: response.message));
        }
      },
    );
  }

  // ==================== ثبت مجدد سفارش ====================
  Future<void> _onReOrder(ReOrderEvent event, Emitter<OrderState> emit) async {
    debugPrint('📋 [OrderBloc] ثبت مجدد سفارش - orderId: ${event.orderId}');
    emit(state.copyWith(status: OrderStatus.loading));

    final result = await _repository.reOrder(event.orderId, event.lat, event.lng);

    result.fold(
      (failure) {
        debugPrint('❌ [OrderBloc] خطا: ${failure.message}');
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (response) {
        if (response.code == 1) {
          debugPrint('✅ [OrderBloc] ثبت مجدد موفق - merchantId: ${response.merchantId}');
          emit(state.copyWith(status: OrderStatus.success));
        } else {
          debugPrint('⚠️ [OrderBloc] ثبت مجدد با خطا: ${response.message}');
          emit(state.copyWith(status: OrderStatus.failure, errorMessage: response.message));
        }
      },
    );
  }

  // ==================== بررسی پیگیری سفارش ====================
  Future<void> _onCheckTrack(CheckTrackEvent event, Emitter<OrderState> emit) async {
    debugPrint('📋 [OrderBloc] بررسی پیگیری سفارش - orderId: ${event.orderId}');
    emit(state.copyWith(status: OrderStatus.loading));

    final result = await _repository.checkTrackHistory(event.orderId, event.lat, event.lng);

    result.fold(
      (failure) {
        debugPrint('❌ [OrderBloc] خطا: ${failure.message}');
        emit(state.copyWith(status: OrderStatus.failure, errorMessage: failure.message));
      },
      (response) {
        if (response.code == 1) {
          debugPrint('✅ [OrderBloc] وضعیت پیگیری: runTrack=${response.runTrack}');
          emit(state.copyWith(status: OrderStatus.success));
        } else {
          debugPrint('⚠️ [OrderBloc] خطا: ${response.message}');
          emit(state.copyWith(status: OrderStatus.failure, errorMessage: response.message));
        }
      },
    );
  }

  // ==================== جستجوی سفارش ====================
  Future<void> _onSearchOrder(SearchOrderEvent event, Emitter<OrderState> emit) async {
    if (event.searchStr.trim().isEmpty) {
      debugPrint('📋 [OrderBloc] عبارت جستجو خالی است');
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    debugPrint('📋 [OrderBloc] جستجوی سفارش - searchStr: ${event.searchStr}');
    emit(state.copyWith(status: OrderStatus.loading, isSearching: true));

    final result = await _repository.searchOrder(event.searchStr, event.lat, event.lng);

    result.fold(
      (failure) {
        debugPrint('❌ [OrderBloc] خطا در جستجو: ${failure.message}');
        emit(state.copyWith(
          status: OrderStatus.failure,
          errorMessage: failure.message,
          searchResults: [],
          isSearching: false,
        ));
      },
      (response) {
        if (response.code == 1 && response.items.isNotEmpty) {
          final results = response.items.map((item) => OrderSearchEntity(
            orderId: item.orderId,
            restaurantName: item.restaurantName,
            logo: item.logo,
            totalWTax: item.totalWTax,
            paymentType: item.paymentType,
            transaction: item.transaction,
          )).toList();
          debugPrint('✅ [OrderBloc] ${results.length} نتیجه یافت شد');
          emit(state.copyWith(
            status: OrderStatus.success,
            searchResults: results,
            isSearching: true,
          ));
        } else {
          debugPrint('📭 [OrderBloc] نتیجه‌ای یافت نشد');
          emit(state.copyWith(
            status: OrderStatus.empty,
            searchResults: [],
            isSearching: true,
          ));
        }
      },
    );
  }

  // ==================== پاک کردن نتایج جستجو ====================
  void _onClearSearch(ClearSearchEvent event, Emitter<OrderState> emit) {
    debugPrint('📋 [OrderBloc] پاک کردن نتایج جستجو');
    emit(state.copyWith(searchResults: [], isSearching: false, status: OrderStatus.success));
  }
}