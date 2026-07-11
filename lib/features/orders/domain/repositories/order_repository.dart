import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import '../../data/models/order_models.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderListResponseDto>> getOrderList(String tab, double lat, double lng);
  Future<Either<Failure, OrderDetailResponseDto>> getOrderDetail(String orderId, double lat, double lng);
  Future<Either<Failure, ReOrderResponseDto>> reOrder(String orderId, double lat, double lng);
  Future<Either<Failure, TrackResponseDto>> checkTrackHistory(String orderId, double lat, double lng);
  Future<Either<Failure, OrderSearchResponseDto>> searchOrder(String searchStr, double lat, double lng);
}