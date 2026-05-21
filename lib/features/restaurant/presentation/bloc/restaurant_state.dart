import 'package:equatable/equatable.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_category_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/item_details_dto.dart';  // ✅ اضافه شده

enum RestaurantStatus { initial, loading, success, failure }
enum MenuLoadingStatus { initial, loading, success, failure }
enum ItemDetailsStatus { initial, loading, success, failure }  // ✅ اضافه شده

class RestaurantState extends Equatable {
  final RestaurantStatus status;
  final MenuLoadingStatus menuStatus;
  final ItemDetailsStatus itemDetailsStatus;  // ✅ اضافه شده
  final RestaurantInfoDto? info;
  final List<MenuCategoryDto> categories;
  final List<MenuItemDto> items;
  final String selectedCategoryId;
  final String errorMessage;
  final ItemDetailsDto? selectedItem;  // ✅ اضافه شده

  const RestaurantState({
    this.status = RestaurantStatus.initial,
    this.menuStatus = MenuLoadingStatus.initial,
    this.itemDetailsStatus = ItemDetailsStatus.initial,  // ✅ اضافه شده
    this.info,
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId = '',
    this.errorMessage = '',
    this.selectedItem,  // ✅ اضافه شده
  });

  RestaurantState copyWith({
    RestaurantStatus? status,
    MenuLoadingStatus? menuStatus,
    ItemDetailsStatus? itemDetailsStatus,  // ✅ اضافه شده
    RestaurantInfoDto? info,
    List<MenuCategoryDto>? categories,
    List<MenuItemDto>? items,
    String? selectedCategoryId,
    String? errorMessage,
    ItemDetailsDto? selectedItem,  // ✅ اضافه شده
  }) {
    return RestaurantState(
      status: status ?? this.status,
      menuStatus: menuStatus ?? this.menuStatus,
      itemDetailsStatus: itemDetailsStatus ?? this.itemDetailsStatus,
      info: info ?? this.info,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    menuStatus, 
    itemDetailsStatus,  // ✅ اضافه شده
    info, 
    categories, 
    items, 
    selectedCategoryId, 
    errorMessage,
    selectedItem,  // ✅ اضافه شده
  ];
}