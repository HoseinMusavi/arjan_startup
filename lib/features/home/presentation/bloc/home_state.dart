part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<String> banners;
  final List<CuisineDto> cuisines;
  final List<MerchantDto> merchants;
  final String errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.banners = const [],
    this.cuisines = const [],
    this.merchants = const [],
    this.errorMessage = '',
  });

  // متد کپی برای تغییر وضعیت بدون از دست دادن داده‌های قبلی
  HomeState copyWith({
    HomeStatus? status,
    List<String>? banners,
    List<CuisineDto>? cuisines,
    List<MerchantDto>? merchants,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      cuisines: cuisines ?? this.cuisines,
      merchants: merchants ?? this.merchants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, banners, cuisines, merchants, errorMessage];
}