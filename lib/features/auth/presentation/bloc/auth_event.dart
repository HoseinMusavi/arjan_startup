part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// رویداد درخواست کد (تایپ شماره موبایل)
class SendOtpRequested extends AuthEvent {
  final String mobile;
  const SendOtpRequested(this.mobile);
  @override
  List<Object> get props => [mobile];
}

// رویداد تایید کد (تایپ کد دریافتی)
class VerifyOtpRequested extends AuthEvent {
  final String mobile;
  final String otp;
  final String token; // توکن موقت (forgot_token)
  
  const VerifyOtpRequested({
    required this.mobile,
    required this.otp,
    required this.token,
  });
  @override
  List<Object> get props => [mobile, otp, token];
}

class AuthLogout extends AuthEvent {}