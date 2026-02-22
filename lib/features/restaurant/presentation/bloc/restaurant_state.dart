part of 'restaurant_bloc.dart';

enum RestaurantStatus { initial, loading, success, failure }
enum MenuLoadingStatus { initial, loading, success, failure }

class RestaurantState extends Equatable {
  final RestaurantStatus status;
  final MenuLoadingStatus menuStatus;
  final RestaurantInfoDto? info;
  final List<MenuCategoryDto> categories;
  final List<MenuItemDto> items;
  final String selectedCategoryId;
  final String errorMessage;

  const RestaurantState({
    this.status = RestaurantStatus.initial,
    this.menuStatus = MenuLoadingStatus.initial,
    this.info,
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId = '',
    this.errorMessage = '',
  });

  RestaurantState copyWith({
    RestaurantStatus? status,
    MenuLoadingStatus? menuStatus,
    RestaurantInfoDto? info,
    List<MenuCategoryDto>? categories,
    List<MenuItemDto>? items,
    String? selectedCategoryId,
    String? errorMessage,
  }) {
    return RestaurantState(
      status: status ?? this.status,
      menuStatus: menuStatus ?? this.menuStatus,
      info: info ?? this.info,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, menuStatus, info, categories, items, selectedCategoryId, errorMessage];
}