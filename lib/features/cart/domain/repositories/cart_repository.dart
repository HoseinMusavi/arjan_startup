import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import '../../data/models/cart_models.dart';
import '../../data/models/cart_details_dto.dart';

abstract class CartRepository {
  Future<Either<Failure, CartCountDto>> getCartCount(String merchantId, double lat, double lng);
  Future<Either<Failure, AddToCartResponseDto>> addToCart(Map<String, dynamic> payload);
  Future<Either<Failure, void>> clearCart(String merchantId);
  Future<Either<Failure, CartDetailsDto>> getCartDetails(String merchantId, double lat, double lng);
  Future<Either<Failure, CartDetailsDto>> getFirstCart(double lat, double lng);  // ✅ اضافه شد
}