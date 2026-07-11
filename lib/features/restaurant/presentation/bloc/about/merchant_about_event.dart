part of 'merchant_about_bloc.dart';

abstract class MerchantAboutEvent extends Equatable {
  const MerchantAboutEvent();
  @override
  List<Object> get props => [];
}

class LoadMerchantAbout extends MerchantAboutEvent {
  final String merchantId;
  final double lat;
  final double lng;
  const LoadMerchantAbout({
    required this.merchantId,
    required this.lat,
    required this.lng,
  });
  @override
  List<Object> get props => [merchantId, lat, lng];
}