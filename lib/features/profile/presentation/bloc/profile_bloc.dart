import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/features/profile/domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// مدیریت وضعیت پروفایل با Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    // ==================== پروفایل ====================
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileChangePasswordRequested>(_onProfileChangePasswordRequested);

    // ==================== کیف پول ====================
    on<ProfilePointsRequested>(_onProfilePointsRequested);
    on<ProfilePointDetailsRequested>(_onProfilePointDetailsRequested);

    // ==================== آدرس‌ها ====================
    on<ProfileAddressesRequested>(_onProfileAddressesRequested);
    on<ProfileAddAddressRequested>(_onProfileAddAddressRequested);
    on<ProfileDeleteAddressRequested>(_onProfileDeleteAddressRequested);
    on<ProfileCountryListRequested>(_onProfileCountryListRequested);

    // ==================== اعلان‌ها ====================
    on<ProfileNotificationsRequested>(_onProfileNotificationsRequested);

    // ==================== خروج ====================
    on<ProfileLogoutRequested>(_onProfileLogoutRequested);
  }

  // ==================== دریافت پروفایل ====================
  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileRequested received');
    emit(ProfileLoading());
    final result = await _repository.getProfile(currentPage: event.currentPage);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  // ==================== بروزرسانی پروفایل ====================
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileUpdateRequested received');
    emit(ProfileUpdateLoading());
    final result = await _repository.updateProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      contactPhone: event.contactPhone,
      emailAddress: event.emailAddress,
      currentPage: event.currentPage,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfileUpdateSuccess('پروفایل با موفقیت به‌روز شد')),
    );
  }

  // ==================== تغییر رمز عبور ====================
  Future<void> _onProfileChangePasswordRequested(
    ProfileChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileChangePasswordRequested received');
    emit(ProfilePasswordChangeLoading());
    final result = await _repository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmNewPassword: event.confirmNewPassword,
      currentPage: event.currentPage,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfilePasswordChangeSuccess('رمز عبور با موفقیت تغییر کرد')),
    );
  }

  // ==================== دریافت خلاصه کیف پول ====================
  Future<void> _onProfilePointsRequested(
    ProfilePointsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfilePointsRequested received');
    emit(ProfilePointsLoading());
    final result = await _repository.getPointSummary(currentPage: event.currentPage);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (points) => emit(ProfilePointsLoaded(points)),
    );
  }

  // ==================== دریافت جزئیات کیف پول ====================
  Future<void> _onProfilePointDetailsRequested(
    ProfilePointDetailsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfilePointDetailsRequested received for type: ${event.pointType}');
    emit(ProfilePointDetailsLoading());
    final result = await _repository.getPointDetails(
      pointType: event.pointType,
      currentPage: event.currentPage,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (details) {
        // عنوان صفحه را از نوع کیف پول استخراج می‌کنیم (برای نمایش در UI)
        String pageTitle = '';
        switch (event.pointType) {
          case 'income_points':
            pageTitle = 'درآمد کیف پول';
            break;
          case 'expenses_points':
            pageTitle = 'هزینه‌ها';
            break;
          case 'expired_points':
            pageTitle = 'امتیازات منقضی شده';
            break;
          case 'points_merchant':
            pageTitle = 'امتیازات فروشگاه';
            break;
          default:
            pageTitle = 'جزئیات کیف پول';
        }
        emit(ProfilePointDetailsLoaded(details, pageTitle));
      },
    );
  }

  // ==================== دریافت لیست آدرس‌ها ====================
  Future<void> _onProfileAddressesRequested(
    ProfileAddressesRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileAddressesRequested received');
    emit(ProfileAddressesLoading());
    final result = await _repository.getAddressList(
      pageAction: event.pageAction,
      currentPage: event.currentPage,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (addresses) => emit(ProfileAddressesLoaded(addresses)),
    );
  }

  // ==================== افزودن آدرس جدید ====================
  Future<void> _onProfileAddAddressRequested(
    ProfileAddAddressRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileAddAddressRequested received');
    emit(ProfileAddressActionLoading());
    final result = await _repository.saveAddress(
      event.addressData,
      currentPage: event.currentPage,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfileAddressActionSuccess('آدرس با موفقیت اضافه شد')),
    );
  }

  // ==================== حذف آدرس ====================
  Future<void> _onProfileDeleteAddressRequested(
    ProfileDeleteAddressRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileDeleteAddressRequested received for id: ${event.id}');
    emit(ProfileAddressActionLoading());
    final result = await _repository.deleteAddress(
      id: event.id,
      currentPage: event.currentPage,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfileAddressActionSuccess('آدرس با موفقیت حذف شد')),
    );
  }

  // ==================== دریافت لیست کشورها ====================
  Future<void> _onProfileCountryListRequested(
    ProfileCountryListRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileCountryListRequested received');
    emit(ProfileCountryListLoading());
    final result = await _repository.getCountryList(currentPage: event.currentPage);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (countries) => emit(ProfileCountryListLoaded(countries)),
    );
  }

  // ==================== دریافت لیست اعلان‌ها ====================
  Future<void> _onProfileNotificationsRequested(
    ProfileNotificationsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileNotificationsRequested received');
    emit(ProfileNotificationsLoading());
    final result = await _repository.getNotifications(currentPage: event.currentPage);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (notifications) => emit(ProfileNotificationsLoaded(notifications)),
    );
  }

  // ==================== خروج از حساب ====================
  Future<void> _onProfileLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('📡 [ProfileBloc] ProfileLogoutRequested received');
    // این رویداد توسط AuthBloc مدیریت می‌شود،
    // اما برای جلوگیری از خطا، یک emit خالی انجام نمی‌دهیم.
    // در واقع فقط یک سیگنال به AuthBloc می‌فرستیم (در UI انجام می‌شود).
    // پس اینجا هیچ کاری نمی‌کنیم.
    emit(ProfileInitial());
  }
}