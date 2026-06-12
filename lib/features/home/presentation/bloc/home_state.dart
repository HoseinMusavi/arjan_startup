part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }
enum SearchStatus { idle, loading, success, empty, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<String> banners;
  final List<CuisineDto> cuisines;
  final List<MerchantDto> nearbyMerchants;
  final List<MerchantDto> specialOffers;
  final List<MerchantDto> featuredMerchants;
  final List<MerchantDto> allMerchants;
  final List<MerchantDto> favoriteMerchants;
  final String errorMessage;
  final SearchStatus searchStatus;
  final List<SearchItemDto> searchResults;
  final String searchQuery;
  final String searchErrorMessage;
  final List<PromoItemDto> promoItems;

  const HomeState({
    this.status = HomeStatus.initial,
    this.banners = const [],
    this.cuisines = const [],
    this.nearbyMerchants = const [],
    this.specialOffers = const [],
    this.featuredMerchants = const [],
    this.allMerchants = const [],
    this.favoriteMerchants = const [],
    this.errorMessage = '',
    this.searchStatus = SearchStatus.idle,
    this.searchResults = const [],
    this.searchQuery = '',
    this.searchErrorMessage = '',
    this.promoItems = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    List<String>? banners,
    List<CuisineDto>? cuisines,
    List<MerchantDto>? nearbyMerchants,
    List<MerchantDto>? specialOffers,
    List<MerchantDto>? featuredMerchants,
    List<MerchantDto>? allMerchants,
    List<MerchantDto>? favoriteMerchants,
    String? errorMessage,
    SearchStatus? searchStatus,
    List<SearchItemDto>? searchResults,
    String? searchQuery,
    String? searchErrorMessage,
    List<PromoItemDto>? promoItems,
  }) {
    return HomeState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      cuisines: cuisines ?? this.cuisines,
      nearbyMerchants: nearbyMerchants ?? this.nearbyMerchants,
      specialOffers: specialOffers ?? this.specialOffers,
      featuredMerchants: featuredMerchants ?? this.featuredMerchants,
      allMerchants: allMerchants ?? this.allMerchants,
      favoriteMerchants: favoriteMerchants ?? this.favoriteMerchants,
      errorMessage: errorMessage ?? this.errorMessage,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      searchErrorMessage: searchErrorMessage ?? this.searchErrorMessage,
      promoItems: promoItems ?? this.promoItems,
    );
  }

  @override
  List<Object> get props => [
        status,
        banners,
        cuisines,
        nearbyMerchants,
        specialOffers,
        featuredMerchants,
        allMerchants,
        favoriteMerchants,
        errorMessage,
        searchStatus,
        searchResults,
        searchQuery,
        searchErrorMessage,
        promoItems,
      ];
}