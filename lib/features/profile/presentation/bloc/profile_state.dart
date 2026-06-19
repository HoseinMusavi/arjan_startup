import 'package:equatable/equatable.dart';
import '../../data/models/profile_dto.dart';
import '../../data/models/point_summary_dto.dart';
import '../../data/models/point_detail_dto.dart';
import '../../data/models/address_dto.dart';
import '../../data/models/notification_dto.dart';

/// تمام وضعیت‌های مربوط به پروفایل
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// ==================== وضعیت‌های اولیه و عمومی ====================

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

// ==================== وضعیت‌های پروفایل ====================

class ProfileLoaded extends ProfileState {
  final ProfileDto profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ProfilePasswordChangeLoading extends ProfileState {}

class ProfilePasswordChangeSuccess extends ProfileState {
  final String message;
  const ProfilePasswordChangeSuccess(this.message);
  @override
  List<Object> get props => [message];
}

// ==================== وضعیت‌های کیف پول ====================

class ProfilePointsLoading extends ProfileState {}

class ProfilePointsLoaded extends ProfileState {
  final List<PointSummaryDto> points;
  const ProfilePointsLoaded(this.points);
  @override
  List<Object> get props => [points];
}

class ProfilePointDetailsLoading extends ProfileState {}

class ProfilePointDetailsLoaded extends ProfileState {
  final List<PointDetailDto> details;
  final String pageTitle;
  const ProfilePointDetailsLoaded(this.details, this.pageTitle);
  @override
  List<Object> get props => [details, pageTitle];
}

// ==================== وضعیت‌های آدرس ====================

class ProfileAddressesLoading extends ProfileState {}

class ProfileAddressesLoaded extends ProfileState {
  final List<AddressDto> addresses;
  const ProfileAddressesLoaded(this.addresses);
  @override
  List<Object> get props => [addresses];
}

class ProfileAddressActionLoading extends ProfileState {}

class ProfileAddressActionSuccess extends ProfileState {
  final String message;
  const ProfileAddressActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ProfileCountryListLoading extends ProfileState {}

class ProfileCountryListLoaded extends ProfileState {
  final Map<String, String> countries;
  const ProfileCountryListLoaded(this.countries);
  @override
  List<Object> get props => [countries];
}

// ==================== وضعیت‌های اعلان‌ها ====================

class ProfileNotificationsLoading extends ProfileState {}

class ProfileNotificationsLoaded extends ProfileState {
  final List<NotificationDto> notifications;
  const ProfileNotificationsLoaded(this.notifications);
  @override
  List<Object> get props => [notifications];
}