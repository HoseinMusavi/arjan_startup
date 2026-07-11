import 'package:equatable/equatable.dart';

/// مدل پاسخ جستجوی دسته‌بندی‌های منو
class SearchCategoryResponseDto extends Equatable {
  final int code;
  final String msg;
  final List<SearchCategoryItemDto> items;

  const SearchCategoryResponseDto({
    required this.code,
    required this.msg,
    required this.items,
  });

  factory SearchCategoryResponseDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final List<dynamic> dataList = details?['data'] ?? [];
    return SearchCategoryResponseDto(
      code: json['code'] as int? ?? 0,
      msg: json['msg']?.toString() ?? '',
      items: dataList
          .map((e) => SearchCategoryItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => code == 1;

  @override
  List<Object?> get props => [code, msg, items];
}

/// مدل یک دسته‌بندی در نتایج جستجو
class SearchCategoryItemDto extends Equatable {
  final String catId;
  final String merchantId;
  final String categoryName;
  final String categoryDescription;
  final String photo;
  final String status;

  const SearchCategoryItemDto({
    required this.catId,
    required this.merchantId,
    required this.categoryName,
    required this.categoryDescription,
    required this.photo,
    required this.status,
  });

  factory SearchCategoryItemDto.fromJson(Map<String, dynamic> json) {
    return SearchCategoryItemDto(
      catId: json['cat_id']?.toString() ?? '',
      merchantId: json['merchant_id']?.toString() ?? '',
      categoryName: _cleanHtmlTags(json['category_name']?.toString() ?? ''),
      categoryDescription: _cleanHtmlTags(json['category_description']?.toString() ?? ''),
      photo: json['photo']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  static String _cleanHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true);
    return htmlText.replaceAll(exp, '').trim();
  }

  @override
  List<Object?> get props => [
        catId,
        merchantId,
        categoryName,
        categoryDescription,
        photo,
        status,
      ];
}