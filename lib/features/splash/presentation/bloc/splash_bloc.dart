import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/config_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ConfigRepository _repository;

  SplashBloc(this._repository) : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    debugPrint('🚀 [Splash] شروع فرآیند اسپلش...');
    emit(const SplashLoading());

    try {
      final response = await _repository.getSettings();
      
      debugPrint('📡 [Splash] پاسخ دریافت شد - تعداد دسته‌بندی‌ها: ${response.cuisines.length}');
      
      emit(SplashLoaded(response));
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (!emit.isDone) {
        emit(const SplashComplete());
      }
      
    } catch (e) {
      debugPrint('❌ [Splash] خطای غیرمنتظره: $e');
      if (!emit.isDone) {
        emit(SplashError('خطا در بارگذاری برنامه: ${e.toString()}'));
      }
    }
  }
}