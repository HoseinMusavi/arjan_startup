import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_category_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/item_details_dto.dart';  // ✅ اضافه شده

abstract class RestaurantRepository {
  Future<Either<Failure, RestaurantInfoDto>> getRestaurantInfo(String merchantId, double lat, double lng);
  Future<Either<Failure, List<MenuCategoryDto>>> getMenuCategories(String merchantId, double lat, double lng);
  Future<Either<Failure, List<MenuItemDto>>> getItemsByCategory(String merchantId, String categoryId, double lat, double lng);
  Future<Either<Failure, ItemDetailsDto>> getItemDetails(String merchantId, String itemId, String categoryId, double lat, double lng);  // ✅ اضافه شده
}