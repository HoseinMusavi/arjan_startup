import 'package:equatable/equatable.dart';

class ItemDetailsDto extends Equatable {
  final int inventoryEnabled;
  final String categoryId;
  final ItemDataDto data;
  final List<ItemDto> items;
  final int paginateTotal;
  final String cartData;
  final bool orderingDisabled;
  final String orderingMsg;

  const ItemDetailsDto({
    required this.inventoryEnabled,
    required this.categoryId,
    required this.data,
    required this.items,
    required this.paginateTotal,
    required this.cartData,
    required this.orderingDisabled,
    required this.orderingMsg,
  });

  factory ItemDetailsDto.fromJson(Map<String, dynamic> json) {
    return ItemDetailsDto(
      inventoryEnabled: json['inventory_enabled'] ?? 0,
      categoryId: json['cat_id']?.toString() ?? '',
      data: ItemDataDto.fromJson(json['data'] ?? {}),
      items: (json['items']?['data'] as List? ?? [])
          .map((e) => ItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      paginateTotal: json['items']?['paginate_total'] ?? 0,
      cartData: json['cart_data']?.toString() ?? '',
      orderingDisabled: json['ordering_disabled'] ?? false,
      orderingMsg: json['ordering_msg']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    inventoryEnabled,
    categoryId,
    data,
    items,
    paginateTotal,
    cartData,
    orderingDisabled,
    orderingMsg,
  ];
}

class ItemDataDto extends Equatable {
  final String merchantId;
  final String itemId;
  final String itemName;
  final String itemDescription;
  final String discount;
  final String photo;
  final List<PriceDto> prices;
  final bool cookingRef;
  final bool addonItem;
  final bool ingredients;
  final String spicydish;
  final String dish;
  final String twoFlavors;
  final String galleryPhoto;
  final String notAvailable;
  final String dishList;
  final List<dynamic> gallery;
  final bool multiplePrice;

  const ItemDataDto({
    required this.merchantId,
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.discount,
    required this.photo,
    required this.prices,
    required this.cookingRef,
    required this.addonItem,
    required this.ingredients,
    required this.spicydish,
    required this.dish,
    required this.twoFlavors,
    required this.galleryPhoto,
    required this.notAvailable,
    required this.dishList,
    required this.gallery,
    required this.multiplePrice,
  });

  factory ItemDataDto.fromJson(Map<String, dynamic> json) {
    return ItemDataDto(
      merchantId: json['merchant_id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      itemDescription: json['item_description']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      prices: (json['prices'] as List? ?? [])
          .map((e) => PriceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      cookingRef: json['cooking_ref'] ?? false,
      addonItem: json['addon_item'] ?? false,
      ingredients: json['ingredients'] ?? false,
      spicydish: json['spicydish']?.toString() ?? '0',
      dish: json['dish']?.toString() ?? '',
      twoFlavors: json['two_flavors']?.toString() ?? '0',
      galleryPhoto: json['gallery_photo']?.toString() ?? '',
      notAvailable: json['not_available']?.toString() ?? '',
      dishList: json['dish_list']?.toString() ?? '',
      gallery: json['gallery'] ?? [],
      multiplePrice: json['multiple_price'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    merchantId, itemId, itemName, itemDescription, discount, photo,
    prices, cookingRef, addonItem, ingredients, spicydish, dish,
    twoFlavors, galleryPhoto, notAvailable, dishList, gallery, multiplePrice,
  ];
}

class PriceDto extends Equatable {
  final String price;
  final String size;
  final int sizeId;
  final String sizeTrans;
  final String formattedPrice;
  final int discountPrice;
  final String formattedDiscountPrice;

  const PriceDto({
    required this.price,
    required this.size,
    required this.sizeId,
    required this.sizeTrans,
    required this.formattedPrice,
    required this.discountPrice,
    required this.formattedDiscountPrice,
  });

  factory PriceDto.fromJson(Map<String, dynamic> json) {
    return PriceDto(
      price: json['price']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      sizeId: json['size_id'] ?? 0,
      sizeTrans: json['size_trans']?.toString() ?? '',
      formattedPrice: json['formatted_price']?.toString() ?? '',
      discountPrice: json['discount_price'] ?? 0,
      formattedDiscountPrice: json['formatted_discount_price']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    price, size, sizeId, sizeTrans, formattedPrice, discountPrice, formattedDiscountPrice,
  ];
}

class ItemDto extends Equatable {
  final String itemId;
  final String merchantId;
  final String itemName;
  final String itemDescription;
  final String status;
  final String price;
  final String photo;
  final String discount;
  final String dish;
  final List<String> prices;
  final List<Price2Dto> prices2;
  final String categoryId;
  final String dishImage;

  const ItemDto({
    required this.itemId,
    required this.merchantId,
    required this.itemName,
    required this.itemDescription,
    required this.status,
    required this.price,
    required this.photo,
    required this.discount,
    required this.dish,
    required this.prices,
    required this.prices2,
    required this.categoryId,
    required this.dishImage,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      itemId: json['item_id']?.toString() ?? '',
      merchantId: json['merchant_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      itemDescription: json['item_description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      dish: json['dish']?.toString() ?? '',
      prices: (json['prices'] as List? ?? []).map((e) => e.toString()).toList(),
      prices2: (json['prices2'] as List? ?? [])
          .map((e) => Price2Dto.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryId: json['cat_id']?.toString() ?? '',
      dishImage: json['dish_image']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    itemId, merchantId, itemName, itemDescription, status, price, photo,
    discount, dish, prices, prices2, categoryId, dishImage,
  ];
}

class Price2Dto extends Equatable {
  final String originalPrice;
  final String discount;
  final String discountedPricePretty;

  const Price2Dto({
    required this.originalPrice,
    required this.discount,
    required this.discountedPricePretty,
  });

  factory Price2Dto.fromJson(Map<String, dynamic> json) {
    return Price2Dto(
      originalPrice: json['original_price']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      discountedPricePretty: json['discounted_price_pretty']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [originalPrice, discount, discountedPricePretty];
}