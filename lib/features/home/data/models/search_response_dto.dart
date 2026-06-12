import 'search_item_dto.dart';

class SearchResponseDto {
  final int code;
  final String msg;
  final List<SearchItemDto> items;

  SearchResponseDto({
    required this.code,
    required this.msg,
    required this.items,
  });

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final List<dynamic> dataList = details?['data'] ?? [];
    
    return SearchResponseDto(
      code: json['code'] as int? ?? 0,
      msg: json['msg']?.toString() ?? '',
      items: dataList.map((e) => SearchItemDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool get isSuccess => code == 1;
}