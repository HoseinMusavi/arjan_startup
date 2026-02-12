import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_config.dart';
import '../../data/repositories/config_repository.dart';

// --- Events ---
abstract class SplashEvent extends Equatable {
  const SplashEvent();
  @override
  List<Object> get props => [];
}

class SplashStarted extends SplashEvent {}

// --- States ---
abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashSuccess extends SplashState {}
class SplashError extends SplashState {
  final String message;
  const SplashError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ConfigRepository _repository;

  SplashBloc(this._repository) : super(SplashInitial()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(SplashStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    try {
      // دریافت تنظیمات از سرور
      final settings = await _repository.getSettings();
      
      // ذخیره در Singleton
      AppConfig().initialize(settings);
      
      emit(SplashSuccess());
    } catch (e) {
      emit(SplashError("خطا در دریافت تنظیمات: $e"));
    }
  }
}