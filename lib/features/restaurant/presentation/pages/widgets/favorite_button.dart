import 'package:arjan_startup/features/restaurant/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/core/di/service_locator.dart';

import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';

class FavoriteButton extends StatelessWidget {
  final String merchantId;
  final double lat;
  final double lng;
  final bool initialValue;

  const FavoriteButton({
    super.key,
    required this.merchantId,
    required this.lat,
    required this.lng,
    this.initialValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteBloc(getIt<RestaurantRepository>())
        ..add(ToggleFavorite(merchantId: merchantId, lat: lat, lng: lng)),
      child: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          final isFavorite = state.isFavorite;
          final isLoading = state.status == FavoriteStatus.loading;
          return IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 28,
            ),
            onPressed: isLoading
                ? null
                : () {
                    context.read<FavoriteBloc>().add(ToggleFavorite(
                          merchantId: merchantId,
                          lat: lat,
                          lng: lng,
                        ));
                  },
          );
        },
      ),
    );
  }
}