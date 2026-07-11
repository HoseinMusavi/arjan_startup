import 'package:equatable/equatable.dart';

/// تمام رویدادهای مربوط به پروفایل
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// ==================== رویدادهای پروفایل ====================

/// دریافت اطلاعات پروفایل (بارگذاری اولیه)
class ProfileRequested extends ProfileEvent {
  final String? currentPage;
  const ProfileRequested({this.currentPage});
  @override
  List<Object?> get props => [currentPage];
}

/// بروزرسانی اطلاعات پروفایل
class ProfileUpdateRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String contactPhone;
  final String emailAddress;
  final String? currentPage;

  const ProfileUpdateRequested({
    required this.firstName,
    required this.lastName,
    required this.contactPhone,
    required this.emailAddress,
    this.currentPage,
  });

  @override
  List<Object?> get props => [firstName, lastName, contactPhone, emailAddress, currentPage];
}

/// تغییر رمز عبور
class ProfileChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;
  final String? currentPage;

  const ProfileChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
    this.currentPage,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmNewPassword, currentPage];
}

// ==================== رویدادهای کیف پول ====================

/// دریافت خلاصه کیف پول
class ProfilePointsRequested extends ProfileEvent {
  final String? currentPage;
  const ProfilePointsRequested({this.currentPage});
  @override
  List<Object?> get props => [currentPage];
}

/// دریافت جزئیات یک بخش از کیف پول (بر اساس نوع)
class ProfilePointDetailsRequested extends ProfileEvent {
  final String pointType;
  final String? currentPage;

  const ProfilePointDetailsRequested({
    required this.pointType,
    this.currentPage,
  });

  @override
  List<Object?> get props => [pointType, currentPage];
}

// ==================== رویدادهای آدرس ====================

/// دریافت لیست آدرس‌ها
class ProfileAddressesRequested extends ProfileEvent {
  final String? pageAction;
  final String? currentPage;

  const ProfileAddressesRequested({this.pageAction, this.currentPage});
  @override
  List<Object?> get props => [pageAction, currentPage];
}

/// افزودن آدرس جدید
class ProfileAddAddressRequested extends ProfileEvent {
  final Map<String, dynamic> addressData;
  final String? currentPage;

  const ProfileAddAddressRequested({
    required this.addressData,
    this.currentPage,
  });

  @override
  List<Object?> get props => [addressData, currentPage];
}

/// حذف آدرس
class ProfileDeleteAddressRequested extends ProfileEvent {
  final String id;
  final String? currentPage;

  const ProfileDeleteAddressRequested({
    required this.id,
    this.currentPage,
  });

  @override
  List<Object?> get props => [id, currentPage];
}

/// دریافت لیست کشورها (برای فرم آدرس)
class ProfileCountryListRequested extends ProfileEvent {
  final String? currentPage;
  const ProfileCountryListRequested({this.currentPage});
  @override
  List<Object?> get props => [currentPage];
}

// ==================== رویدادهای اعلان‌ها ====================

/// دریافت لیست اعلان‌ها
class ProfileNotificationsRequested extends ProfileEvent {
  final String? currentPage;
  const ProfileNotificationsRequested({this.currentPage});
  @override
  List<Object?> get props => [currentPage];
}

// ==================== رویداد خروج ====================

/// خروج از حساب کاربری (مدیریت توسط AuthBloc)
class ProfileLogoutRequested extends ProfileEvent {}