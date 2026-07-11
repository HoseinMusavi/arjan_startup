import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import '../../data/models/cart_models.dart';
import '../../data/models/cart_details_dto.dart';
import '../../data/models/address_model.dart';
import '../../data/models/delivery_time_model.dart';
import '../../data/models/payment_method_model.dart';

abstract class CartRepository {
  Future<Either<Failure, CartCountDto>> getCartCount(String merchantId, double lat, double lng);
  Future<Either<Failure, AddToCartResponseDto>> addToCart(Map<String, dynamic> payload);
  Future<Either<Failure, void>> clearCart(String merchantId);
  Future<Either<Failure, CartDetailsDto>> getCartDetails(String merchantId, double lat, double lng);
  Future<Either<Failure, CartDetailsDto>> getFirstCart(double lat, double lng);
  
  // APIهای جدید
  Future<Either<Failure, List<AddressDto>>> getAddressBookDropDown();
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
  });
  Future<Either<Failure, Map<String, String>>> getDeliveryDateList(String merchantId);
  Future<Either<Failure, Map<String, String>>> getDeliveryTimeList(String merchantId, String deliveryDate);
  Future<Either<Failure, RedeemPointsResponseDto>> applyRedeemPoints(int points, String merchantId);
  Future<Either<Failure, PreCheckoutResponseDto>> preCheckout({
    required String transactionType,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  });
  Future<Either<Failure, PayNowResponseDto>> payNow({
    required String transactionType,
    required String paymentProvider,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  });
  Future<Either<Failure, List<PaymentMethodDto>>> getPaymentList(String merchantId, double lat, double lng);
}