import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:flutter/widgets.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_source.dart';
import '../models/cart_models.dart';
import '../models/cart_details_dto.dart';
import '../models/address_model.dart';
import '../models/delivery_time_model.dart';
import '../models/payment_method_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _dataSource;
  
  CartRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, CartCountDto>> getCartCount(String merchantId, double lat, double lng) async {
    try {
      final result = await _dataSource.getCartCount(merchantId, lat, lng);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddToCartResponseDto>> addToCart(Map<String, dynamic> payload) async {
    try {
      final result = await _dataSource.addToCart(payload);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart(String merchantId) async {
    try {
      await _dataSource.clearCart(merchantId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartDetailsDto>> getCartDetails(String merchantId, double lat, double lng) async {
    try {
      final result = await _dataSource.getCartDetails(merchantId, lat, lng);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartDetailsDto>> getFirstCart(double lat, double lng) async {
    try {
      debugPrint('🛒 [REPO] دریافت اولین سبد خرید');
      final result = await _dataSource.getFirstCart(lat, lng);
      return Right(result);
    } catch (e) {
      debugPrint('❌ [REPO] خطا در getFirstCart: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== APIهای جدید ====================

  @override
  Future<Either<Failure, List<AddressDto>>> getAddressBookDropDown() async {
    try {
      final result = await _dataSource.getAddressBookDropDown();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressResponseDto>> setDeliveryAddress({
    required double lat,
    required double lng,
    required String street,
    required String city,
    required String state,
    required String zipcode,
    required String countryCode,
    required String locationName,
    required String contactPhone,
    required String merchantId,
  }) async {
    try {
      final result = await _dataSource.setDeliveryAddress(
        lat: lat,
        lng: lng,
        street: street,
        city: city,
        state: state,
        zipcode: zipcode,
        countryCode: countryCode,
        locationName: locationName,
        contactPhone: contactPhone,
        merchantId: merchantId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getDeliveryDateList(String merchantId) async {
    try {
      final result = await _dataSource.getDeliveryDateList(merchantId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getDeliveryTimeList(String merchantId, String deliveryDate) async {
    try {
      final result = await _dataSource.getDeliveryTimeList(merchantId, deliveryDate);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RedeemPointsResponseDto>> applyRedeemPoints(int points, String merchantId) async {
    try {
      final result = await _dataSource.applyRedeemPoints(points, merchantId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PreCheckoutResponseDto>> preCheckout({
    required String transactionType,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  }) async {
    try {
      final result = await _dataSource.preCheckout(
        transactionType: transactionType,
        deliveryDate: deliveryDate,
        deliveryTime: deliveryTime,
        merchantId: merchantId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PayNowResponseDto>> payNow({
    required String transactionType,
    required String paymentProvider,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  }) async {
    try {
      final result = await _dataSource.payNow(
        transactionType: transactionType,
        paymentProvider: paymentProvider,
        deliveryDate: deliveryDate,
        deliveryTime: deliveryTime,
        merchantId: merchantId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodDto>>> getPaymentList(String merchantId, double lat, double lng) async {
    try {
      final result = await _dataSource.getPaymentList(merchantId, lat, lng);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}