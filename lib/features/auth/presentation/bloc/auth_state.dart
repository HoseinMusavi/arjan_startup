part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

// وضعیت موفقیت ارسال کد (حاوی توکن موقت برای مرحله بعد)
class OtpSentSuccess extends AuthState {
  final String token; // forgot_password_token
  final String mobile;
  
  const OtpSentSuccess({required this.token, required this.mobile});
  @override
  List<Object> get props => [token, mobile];
}

// وضعیت موفقیت آمیز نهایی (لاگین کامل)
class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}