import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
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
      final data = await _dataSource.getHomeData();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MerchantDto>>> getMerchants() async {
    try {
      final data = await _dataSource.getMerchants();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}