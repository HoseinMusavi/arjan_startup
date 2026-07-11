import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';
import '../../data/models/search_response_dto.dart';
import '../../data/models/promo_item_dto.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<String>>> getBanners();
  Future<Either<Failure, List<CuisineDto>>> getCuisines(double lat, double lng);
  Future<Either<Failure, List<MerchantDto>>> getMerchants(
    String searchType,
    double lat,
    double lng, {
    String? cuisineId,
  });
  Future<Either<Failure, List<MerchantDto>>> getMerchantsByBanner({
    required String bannerId,
    required double lat,
    required double lng,
  });
  Future<Either<Failure, List<MerchantDto>>> getFavoriteMerchants({
    required double lat,
    required double lng,
  });
  Future<Either<Failure, SearchResponseDto>> searchMerchantFood({
    required String query,
    required double lat,
    required double lng,
  });
  Future<Either<Failure, PromoResponseDto>> getFoodPromo({
    required double lat,
    required double lng,
  });
}