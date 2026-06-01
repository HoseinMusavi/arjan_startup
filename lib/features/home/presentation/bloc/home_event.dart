part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeStarted extends HomeEvent {
  // ✅ اضافه کردن پارامتر cuisineId برای فیلتر
  final String? cuisineId;
  
  const HomeStarted({this.cuisineId});
  
  @override
  List<Object> get props => [cuisineId ?? ''];
}

class HomeRefreshed extends HomeEvent {
  final String? cuisineId;
  
  const HomeRefreshed({this.cuisineId});
  
  @override
  List<Object> get props => [cuisineId ?? ''];
}