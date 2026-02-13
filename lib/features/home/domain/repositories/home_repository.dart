import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';

abstract class HomeRepository {
  Future<Either<Failure, Map<String, dynamic>>> getHomeData(); // شامل بنر و دسته‌بندی
  Future<Either<Failure, List<MerchantDto>>> getMerchants();
}