part of 'restaurant_bloc.dart';

enum RestaurantStatus { initial, loading, success, failure }
enum MenuLoadingStatus { initial, loading, success, failure }
enum ItemDetailsStatus { initial, loading, success, failure }
enum SearchMenuStatus { idle, loading, success, empty, failure }

class RestaurantState extends Equatable {
  final RestaurantStatus status;
  final MenuLoadingStatus menuStatus;
  final ItemDetailsStatus itemDetailsStatus;
  final SearchMenuStatus searchMenuStatus;
  final RestaurantInfoDto? info;
  final List<MenuCategoryDto> categories;
  final List<MenuItemDto> items;
  final String selectedCategoryId;
  final String errorMessage;
  final ItemDetailsDto? selectedItem;
  final List<SearchCategoryItemDto> searchResults;
  final String searchQuery;

  const RestaurantState({
    this.status = RestaurantStatus.initial,
    this.menuStatus = MenuLoadingStatus.initial,
    this.itemDetailsStatus = ItemDetailsStatus.initial,
    this.searchMenuStatus = SearchMenuStatus.idle,
    this.info,
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId = '',
    this.errorMessage = '',
    this.selectedItem,
    this.searchResults = const [],
    this.searchQuery = '',
  });

  RestaurantState copyWith({
    RestaurantStatus? status,
    MenuLoadingStatus? menuStatus,
    ItemDetailsStatus? itemDetailsStatus,
    SearchMenuStatus? searchMenuStatus,
    RestaurantInfoDto? info,
    List<MenuCategoryDto>? categories,
    List<MenuItemDto>? items,
    String? selectedCategoryId,
    String? errorMessage,
    ItemDetailsDto? selectedItem,
    List<SearchCategoryItemDto>? searchResults,
    String? searchQuery,
  }) {
    return RestaurantState(
      status: status ?? this.status,
      menuStatus: menuStatus ?? this.menuStatus,
      itemDetailsStatus: itemDetailsStatus ?? this.itemDetailsStatus,
      searchMenuStatus: searchMenuStatus ?? this.searchMenuStatus,
      info: info ?? this.info,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedItem: selectedItem ?? this.selectedItem,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    menuStatus,
    itemDetailsStatus,
    searchMenuStatus,
    info,
    categories,
    items,
    selectedCategoryId,
    errorMessage,
    selectedItem,
    searchResults,
    searchQuery,
  ];
}