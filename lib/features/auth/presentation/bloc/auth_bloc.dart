import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Events ---
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

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String mobile;
  final String password;

  RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.password,
  });
}

// --- States ---
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String tempToken;
  final String mobile;
  OtpSentSuccess(this.tempToken, this.mobile);
  @override
  List<Object> get props => [tempToken, mobile];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

// --- Bloc ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    
    // 1. ارسال درخواست کد تایید
    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.requestOtp(event.mobile);
      result.fold(
        (error) => emit(AuthFailure(error.toString())),
        (token) => emit(OtpSentSuccess(token, event.mobile)),
      );
    });

    // 2. تایید کد و لاگین
    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.verifyOtp(event.mobile, event.token, event.code);
      result.fold(
        (error) => emit(AuthFailure(error.toString())),
        (user) => emit(AuthSuccess()),
      );
    });

    // 3. ثبت نام
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.register(
        event.firstName, 
        event.lastName, 
        event.mobile, 
        event.password
      );
      result.fold(
        (error) => emit(AuthFailure(error.toString())),
        (user) => emit(AuthSuccess()),
      );
    });
  }
}