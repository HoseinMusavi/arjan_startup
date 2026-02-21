import 'dart:developer';
import '../../../../core/network/dio_client.dart';
import '../models/merchant_dto.dart';
import '../models/cuisine_dto.dart';

abstract class HomeRemoteDataSource {
  Future<List<MerchantDto>> getMerchants(String searchType, double lat, double lng);
  Future<List<CuisineDto>> getCuisines(double lat, double lng);
  Future<List<String>> getBanners();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<MerchantDto>> getMerchants(String searchType, double lat, double lng) async {
    try {
      final response = await _dioClient.get(
        '/searchMerchant',
        queryParameters: {
          'search_type': searchType,
          'lat': lat,
          'lng': lng,
        },
      );

      final data = response.data;
      if (data['code'] == 2) return []; 

      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        // ✅ تعیین دقیق نوع برای جلوگیری از ارور List<dynamic>
        return list.map<MerchantDto>((json) => MerchantDto.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('🔴 Error getMerchants ($searchType): $e');
      return [];
    }
  }

  @override
  Future<List<CuisineDto>> getCuisines(double lat, double lng) async {
    try {
      final response = await _dioClient.get(
        '/cuisineList',
        queryParameters: {
          'carousel': '1',
          'lat': lat,
          'lng': lng,
        },
      );

      final data = response.data;
      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('🟢 Cuisines Fetched: ${list.length}');
        // ✅ حل ارور fromJson و List<dynamic>
        return list.map<CuisineDto>((e) => CuisineDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('🔴 Error getCuisines: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getBanners() async {
    try {
      final response = await _dioClient.get('/getSettings');
      final data = response.data;

      if (data['code'] == 1 && data['details'] != null) {
        final details = data['details'];
        if (details['settings'] != null && details['settings']['home_banner'] != null) {
          final List<dynamic> bannersRaw = details['settings']['home_banner'];
          return bannersRaw.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      log('🔴 Error getBanners: $e');
      return [];
    }
  }
}