part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<String> banners;
  final List<CuisineDto> cuisines;
  final List<MerchantDto> nearbyMerchants;
  final List<MerchantDto> specialOffers; // جدید
  final List<MerchantDto> featuredMerchants;
  final List<MerchantDto> allMerchants;
  final String errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.banners = const [],
    this.cuisines = const [],
    this.nearbyMerchants = const [],
    this.specialOffers = const [],
    this.featuredMerchants = const [],
    this.allMerchants = const [],
    this.errorMessage = '',
  });

  HomeState copyWith({
    HomeStatus? status,
    List<String>? banners,
    List<CuisineDto>? cuisines,
    List<MerchantDto>? nearbyMerchants,
    List<MerchantDto>? specialOffers,
    List<MerchantDto>? featuredMerchants,
    List<MerchantDto>? allMerchants,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      cuisines: cuisines ?? this.cuisines,
      nearbyMerchants: nearbyMerchants ?? this.nearbyMerchants,
      specialOffers: specialOffers ?? this.specialOffers,
      featuredMerchants: featuredMerchants ?? this.featuredMerchants,
      allMerchants: allMerchants ?? this.allMerchants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, banners, cuisines, nearbyMerchants, specialOffers, featuredMerchants, allMerchants, errorMessage];
}