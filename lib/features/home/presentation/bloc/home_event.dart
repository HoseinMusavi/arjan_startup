part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeStarted extends HomeEvent {
  // این رویداد وقتی صفحه باز می‌شود صدا زده می‌شود
}

class HomeRefreshed extends HomeEvent {
  // این رویداد وقتی کاربر صفحه را پایین می‌کشد (Pull to Refresh) صدا زده می‌شود
}