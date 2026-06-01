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

  // ✅ اضافه شده: ثبت‌نام کاربر جدید
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
      (user) {
        debugPrint("✅ [AUTH] ثبت‌نام موفق - ورود کاربر: ${user.firstName}");
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