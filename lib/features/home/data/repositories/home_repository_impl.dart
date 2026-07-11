import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_source.dart';
import '../models/cuisine_dto.dart';
import '../models/merchant_dto.dart';
import '../models/search_response_dto.dart';
import '../models/promo_item_dto.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _dataSource;
  HomeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<String>>> getBanners() async {
    try {
      return Right(await _dataSource.getBanners());
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت بنرها"));
    }
  }

  @override
  Future<Either<Failure, List<CuisineDto>>> getCuisines(double lat, double lng) async {
    try {
      return Right(await _dataSource.getCuisines(lat, lng));
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت دسته‌بندی‌ها"));
    }
  }

  @override
  Future<Either<Failure, List<MerchantDto>>> getMerchants(
    String searchType,
    double lat,
    double lng, {
    String? cuisineId,
  }) async {
    try {
      return Right(await _dataSource.getMerchants(searchType, lat, lng, cuisineId: cuisineId));
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت لیست فروشگاه‌ها"));
    }
  }

  @override
  Future<Either<Failure, List<MerchantDto>>> getMerchantsByBanner({
    required String bannerId,
    required double lat,
    required double lng,
  }) async {
    try {
      return Right(await _dataSource.getMerchantsByBanner(bannerId: bannerId, lat: lat, lng: lng));
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت فروشگاه‌های بنر"));
    }
  }

  @override
  Future<Either<Failure, List<MerchantDto>>> getFavoriteMerchants({
    required double lat,
    required double lng,
  }) async {
    try {
      return Right(await _dataSource.getFavoriteMerchants(lat: lat, lng: lng));
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت فروشگاه‌های مورد علاقه"));
    }
  }

  @override
  Future<Either<Failure, SearchResponseDto>> searchMerchantFood({
    required String query,
    required double lat,
    required double lng,
  }) async {
    try {
      final result = await _dataSource.searchMerchantFood(query: query, lat: lat, lng: lng);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure("خطا در جستجو: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, PromoResponseDto>> getFoodPromo({
    required double lat,
    required double lng,
  }) async {
    try {
      final result = await _dataSource.getFoodPromo(lat: lat, lng: lng);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت تخفیف‌ها: ${e.toString()}"));
    }
  }
}