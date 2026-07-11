part of 'merchant_about_bloc.dart';



enum MerchantAboutStatus { initial, loading, success, failure }

class MerchantAboutState extends Equatable {
  final MerchantAboutStatus status;
  final MerchantAboutDto? about;
  final String errorMessage;

  const MerchantAboutState({
    this.status = MerchantAboutStatus.initial,
    this.about,
    this.errorMessage = '',
  });

  MerchantAboutState copyWith({
    MerchantAboutStatus? status,
    MerchantAboutDto? about,
    String? errorMessage,
  }) {
    return MerchantAboutState(
      status: status ?? this.status,
      about: about ?? this.about,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, about, errorMessage];
}