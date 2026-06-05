import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_source.dart';
import '../models/order_models.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _dataSource;

  OrderRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, OrderListResponseDto>> getOrderList(String tab, double lat, double lng) async {
    try {
      debugPrint('📋 [OrderRepo] دریافت لیست سفارشات - tab: $tab');
      final result = await _dataSource.getOrderList(tab, lat, lng);
      return Right(result);
    } catch (e) {
      debugPrint('❌ [OrderRepo] خطا: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderDetailResponseDto>> getOrderDetail(String orderId, double lat, double lng) async {
    try {
      debugPrint('📋 [OrderRepo] دریافت جزییات سفارش - orderId: $orderId');
      final result = await _dataSource.getOrderDetail(orderId, lat, lng);
      return Right(result);
    } catch (e) {
      debugPrint('❌ [OrderRepo] خطا: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReOrderResponseDto>> reOrder(String orderId, double lat, double lng) async {
    try {
      debugPrint('📋 [OrderRepo] ثبت مجدد سفارش - orderId: $orderId');
      final result = await _dataSource.reOrder(orderId, lat, lng);
      return Right(result);
    } catch (e) {
      debugPrint('❌ [OrderRepo] خطا: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrackResponseDto>> checkTrackHistory(String orderId, double lat, double lng) async {
    try {
      debugPrint('📋 [OrderRepo] بررسی پیگیری سفارش - orderId: $orderId');
      final result = await _dataSource.checkTrackHistory(orderId, lat, lng);
      return Right(result);
    } catch (e) {
      debugPrint('❌ [OrderRepo] خطا: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderSearchResponseDto>> searchOrder(String searchStr, double lat, double lng) async {
    try {
      debugPrint('📋 [OrderRepo] جستجوی سفارش - searchStr: $searchStr');
      final result = await _dataSource.searchOrder(searchStr, lat, lng);
      return Right(result);
    } catch (e) {
      debugPrint('❌ [OrderRepo] خطا: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}