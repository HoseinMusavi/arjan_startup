import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class SendOtpRequested extends AuthEvent {
  final String mobile;
  SendOtpRequested(this.mobile);
}
class VerifyOtpRequested extends AuthEvent {
  final String mobile;
  final String token;
  final String code;
  VerifyOtpRequested({required this.mobile, required this.token, required this.code});
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class OtpSentSuccess extends AuthState {
  final String tempToken; // توکن موقت برای مرحله بعد
  final String mobile;
  OtpSentSuccess(this.tempToken, this.mobile);
}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    
    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.requestOtp(event.mobile);
      result.fold(
        (error) => emit(AuthFailure(error.message)),
        (token) => emit(OtpSentSuccess(token, event.mobile)),
      );
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.verifyOtp(event.mobile, event.token, event.code);
      result.fold(
        (error) => emit(AuthFailure(error.message)),
        (user) => emit(AuthSuccess()),
      );
    });
  }
}