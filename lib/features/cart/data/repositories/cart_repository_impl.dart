import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_source.dart';
import '../models/cart_models.dart';
import '../models/cart_details_dto.dart';

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
}