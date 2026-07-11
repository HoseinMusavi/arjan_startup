import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<CreateAccountRequested>(_onCreateAccountRequested);
    on<VerifyAccountRequested>(_onVerifyAccountRequested);
    on<AuthLogout>(_onAuthLogout);
  }

  Future<void> _onSendOtpRequested(SendOtpRequested event, Emitter<AuthState> emit) async {
    debugPrint("📱 [AUTH] درخواست ارسال OTP برای شماره: ${event.mobile}");
    emit(AuthLoading());
    
    final result = await _repository.requestOtp(event.mobile);
    
    result.fold(
      (failure) {
        debugPrint("❌ [AUTH] خطا در ارسال OTP: ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (token) {
        debugPrint("✅ [AUTH] OTP ارسال شد - token: $token");
        emit(OtpSentSuccess(token: token, mobile: event.mobile));
      },
    );
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    debugPrint("📱 [AUTH] تایید OTP برای شماره: ${event.mobile}");
    debugPrint("   - otp: ${event.otp}");
    debugPrint("   - token: ${event.token}");
    
    emit(AuthLoading());
    
    final result = await _repository.verifyOtp(event.mobile, event.otp, event.token);
    
    result.fold(
      (failure) {
        debugPrint("❌ [AUTH] خطا در تایید OTP: ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (user) {
        debugPrint("✅ [AUTH] تایید OTP موفق - ورود کاربر: ${user.firstName}");
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onCreateAccountRequested(CreateAccountRequested event, Emitter<AuthState> emit) async {
    debugPrint("📝 [AUTH] درخواست ثبت‌نام: ${event.firstName} ${event.lastName}, شماره: ${event.mobile}");
    emit(AuthLoading());
    
    final result = await _repository.createAccount(
      firstName: event.firstName,
      lastName: event.lastName,
      mobile: event.mobile,
      lat: event.lat,
      lng: event.lng,
    );
    
    result.fold(
      (failure) {
        debugPrint("❌ [AUTH] خطا در ثبت‌نام: ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (data) {
        final customerToken = data['customer_token'] ?? '';
        final contactPhone = data['contact_phone'] ?? event.mobile;
        final message = data['message'] ?? 'کد تایید ارسال شد';
        
        debugPrint("✅ [AUTH] ثبت‌نام اولیه موفق - customer_token: $customerToken");
        debugPrint("📱 [AUTH] کد تایید به شماره $contactPhone ارسال شد");
        
        // ✅ رفتن به حالت تایید کد
        emit(AccountCreatedSuccess(
          customerToken: customerToken,
          mobile: contactPhone,
          message: message,
        ));
      },
    );
  }

  Future<void> _onVerifyAccountRequested(VerifyAccountRequested event, Emitter<AuthState> emit) async {
    debugPrint("📱 [AUTH] تایید ثبت‌نام برای شماره: ${event.mobile}");
    debugPrint("   - otp: ${event.otp}");
    debugPrint("   - customerToken: ${event.customerToken}");
    
    emit(AuthLoading());
    
    final result = await _repository.verifyAccount(
      mobile: event.mobile,
      otp: event.otp,
      customerToken: event.customerToken,
    );
    
    result.fold(
      (failure) {
        debugPrint("❌ [AUTH] خطا در تایید ثبت‌نام: ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (user) {
        debugPrint("✅ [AUTH] تایید ثبت‌نام موفق - ورود کاربر: ${user.firstName}");
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    debugPrint("📱 [AUTH] خروج از حساب کاربری");
    await _repository.logout();
    emit(AuthInitial());
  }
}