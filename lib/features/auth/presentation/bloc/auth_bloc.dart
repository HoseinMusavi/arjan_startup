import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    
    // هندلر ارسال کد
    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.requestOtp(event.mobile);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (token) => emit(OtpSentSuccess(token: token, mobile: event.mobile)),
      );
    });

    // هندلر تایید کد
    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await _repository.verifyOtp(event.mobile, event.otp, event.token);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    // هندلر خروج
    on<AuthLogout>((event, emit) async {
      await _repository.logout();
      emit(AuthInitial());
    });
  }
}