part of 'favorite_bloc.dart';

enum FavoriteStatus { initial, loading, success, failure }

class FavoriteState extends Equatable {
  final FavoriteStatus status;
  final bool isFavorite;
  final String message;
  final String errorMessage;

  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.isFavorite = false,
    this.message = '',
    this.errorMessage = '',
  });

  FavoriteState copyWith({
    FavoriteStatus? status,
    bool? isFavorite,
    String? message,
    String? errorMessage,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isFavorite, message, errorMessage];
}