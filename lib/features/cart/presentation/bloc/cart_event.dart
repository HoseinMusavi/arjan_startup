import 'package:equatable/equatable.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class LoadCartCount extends CartEvent {
  final String merchantId;
  final double lat;
  final double lng;
  const LoadCartCount(this.merchantId, this.lat, this.lng);
  @override
  List<Object> get props => [merchantId, lat, lng];
}

class AddItemToCart extends CartEvent {
  final MenuItemDto item;
  final String merchantId;
  final String categoryId;
  final double lat;
  final double lng;
  const AddItemToCart({required this.item, required this.merchantId, required this.categoryId, required this.lat, required this.lng});
  @override
  List<Object> get props => [item, merchantId, categoryId, lat, lng];
}

class ClearCartAndAddItem extends CartEvent {
  final MenuItemDto item;
  final String merchantId;
  final String categoryId;
  final double lat;
  final double lng;
  const ClearCartAndAddItem({required this.item, required this.merchantId, required this.categoryId, required this.lat, required this.lng});
  @override
  List<Object> get props => [item, merchantId, categoryId, lat, lng];
}

class LoadCartDetails extends CartEvent {
  final double lat;
  final double lng;
  const LoadCartDetails(this.lat, this.lng);
  @override
  List<Object> get props => [lat, lng];
}

class RemoveItemFromCart extends CartEvent {
  final String itemId;
  final double lat;
  final double lng;
  const RemoveItemFromCart({required this.itemId, required this.lat, required this.lng});
  @override
  List<Object> get props => [itemId, lat, lng];
}

class UpdateItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;
  final double lat;
  final double lng;
  const UpdateItemQuantity({required this.itemId, required this.quantity, required this.lat, required this.lng});
  @override
  List<Object> get props => [itemId, quantity, lat, lng];
}

// ✅ اضافه شد
class LoadFirstCart extends CartEvent {
  final double lat;
  final double lng;
  const LoadFirstCart(this.lat, this.lng);
  @override
  List<Object> get props => [lat, lng];
}