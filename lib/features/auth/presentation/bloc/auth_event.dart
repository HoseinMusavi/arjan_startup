part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String mobile;
  const SendOtpRequested(this.mobile);
  @override
  List<Object> get props => [mobile];
}

class VerifyOtpRequested extends AuthEvent {
  final String mobile;
  final String otp;
  final String token;
  
  const VerifyOtpRequested({
    required this.mobile,
    required this.otp,
    required this.token,
  });
  @override
  List<Object> get props => [mobile, otp, token];
}

// ✅ اضافه شده: رویداد ثبت‌نام
class CreateAccountRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String mobile;
  final double lat;
  final double lng;
  
  const CreateAccountRequested({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.lat,
    required this.lng,
  });
  @override
  List<Object> get props => [firstName, lastName, mobile, lat, lng];
}

class AuthLogout extends AuthEvent {}