import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<String>>> getBanners();
  Future<Either<Failure, List<CuisineDto>>> getCuisines();
  Future<Either<Failure, List<MerchantDto>>> getMerchants(String searchType, double lat, double lng);
}