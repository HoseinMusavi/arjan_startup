import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_source.dart';
import '../models/restaurant_info_dto.dart';
import '../models/menu_category_dto.dart';
import '../models/menu_item_dto.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource _dataSource;

  RestaurantRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, RestaurantInfoDto>> getRestaurantInfo(String merchantId, double lat, double lng) async {
    log('🔄 [Repo] درخواست اطلاعات رستوران به دیتاسورس ارسال شد.');
    try {
      final result = await _dataSource.getRestaurantInfo(merchantId, lat, lng);
      if (result != null) return Right(result);
      return Left(ServerFailure("اطلاعات رستوران یافت نشد"));
    } catch (e) {
      log('❌ [Repo] خطا: $e');
      return Left(ServerFailure("خطای ارتباط با سرور"));
    }
  }

  @override
  Future<Either<Failure, List<MenuCategoryDto>>> getMenuCategories(String merchantId, double lat, double lng) async {
    log('🔄 [Repo] درخواست دسته‌بندی‌های منو به دیتاسورس ارسال شد.');
    try {
      final result = await _dataSource.getMenuCategories(merchantId, lat, lng);
      return Right(result);
    } catch (e) {
      log('❌ [Repo] خطا: $e');
      return Left(ServerFailure("خطای ارتباط با سرور در دریافت منو"));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemDto>>> getItemsByCategory(String merchantId, String categoryId, double lat, double lng) async {
    log('🔄 [Repo] درخواست غذاهای منو به دیتاسورس ارسال شد.');
    try {
      final result = await _dataSource.getItemsByCategory(merchantId, categoryId, lat, lng);
      return Right(result);
    } catch (e) {
      log('❌ [Repo] خطا: $e');
      return Left(ServerFailure("خطای ارتباط با سرور در دریافت غذاها"));
    }
  }
}