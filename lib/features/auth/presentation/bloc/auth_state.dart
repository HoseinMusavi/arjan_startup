part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String token;
  final String mobile;
  
  const OtpSentSuccess({required this.token, required this.mobile});
  @override
  List<Object> get props => [token, mobile];
}

// ✅ وضعیت جدید: ثبت‌نام اولیه موفق - نیاز به تایید کد
class AccountCreatedSuccess extends AuthState {
  final String customerToken;
  final String mobile;
  final String message;
  
  const AccountCreatedSuccess({
    required this.customerToken,
    required this.mobile,
    required this.message,
  });
  @override
  List<Object> get props => [customerToken, mobile, message];
}

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