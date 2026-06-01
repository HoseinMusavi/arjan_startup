import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_source.dart';
import '../models/cuisine_dto.dart';
import '../models/merchant_dto.dart';

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
}