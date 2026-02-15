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
  Future<Either<Failure, Map<String, dynamic>>> getHomeData() async {
    try {
      return Right(await _dataSource.getHomeData());
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت بنرها"));
    }
  }

  @override
  Future<Either<Failure, List<CuisineDto>>> getCuisines() async {
    try {
      return Right(await _dataSource.getCuisines());
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت دسته‌بندی"));
    }
  }

  @override
  Future<Either<Failure, List<MerchantDto>>> getMerchants(String searchType) async {
    try {
      return Right(await _dataSource.getMerchants(searchType: searchType));
    } catch (e) {
      return Left(ServerFailure("خطا در دریافت لیست رستوران"));
    }
  }
}