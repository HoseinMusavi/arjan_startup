import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/restaurant_info_dto.dart';
import '../../data/models/menu_category_dto.dart';
import '../../data/models/menu_item_dto.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, RestaurantInfoDto>> getRestaurantInfo(String merchantId, double lat, double lng);
  Future<Either<Failure, List<MenuCategoryDto>>> getMenuCategories(String merchantId, double lat, double lng);
  Future<Either<Failure, List<MenuItemDto>>> getItemsByCategory(String merchantId, String categoryId, double lat, double lng);
}