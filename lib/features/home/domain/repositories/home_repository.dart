import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';

abstract class HomeRepository {
  Future<Either<Failure, Map<String, dynamic>>> getHomeData();
  Future<Either<Failure, List<CuisineDto>>> getCuisines();
  Future<Either<Failure, List<MerchantDto>>> getMerchants(String searchType);
}