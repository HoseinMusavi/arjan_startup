import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/merchant_dto.dart';
import '../models/cuisine_dto.dart';

abstract class HomeRemoteDataSource {
  Future<List<MerchantDto>> getMerchants(String searchType, double lat, double lng);
  Future<List<CuisineDto>> getCuisines();
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
      
      if (data['code'] == 2) {
        return [];
      }

      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        return list.map((json) => MerchantDto.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      log('🔴 Error in getMerchants ($searchType): $e');
      return [];
    }
  }

  @override
  Future<List<CuisineDto>> getCuisines() async {
    try {
      final response = await _dioClient.get('/getSettings');
      final data = response.data;

      if (data['code'] == 1 && data['details'] != null) {
        // تغییر مهم در این بخش: گاهی 'settings' وجود ندارد و مستقیم داخل 'details' است.
        final details = data['details'];
        List<dynamic> cuisinesRaw = [];
        
        if (details['settings'] != null && details['settings']['cuisine'] != null) {
           cuisinesRaw = details['settings']['cuisine'];
        } else if (details['cuisine'] != null) {
           cuisinesRaw = details['cuisine'];
        }

        if (cuisinesRaw.isNotEmpty) {
          log('🟢 Cuisines Parsed: ${cuisinesRaw.length}');
          return cuisinesRaw.map((e) => CuisineDto.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      log('🔴 Error in getCuisines: $e');
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
        List<dynamic> bannersRaw = [];

        if (details['settings'] != null && details['settings']['home_banner'] != null) {
          bannersRaw = details['settings']['home_banner'];
        } else if (details['home_banner'] != null) {
          bannersRaw = details['home_banner'];
        }

        if (bannersRaw.isNotEmpty) {
          return bannersRaw.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      log('🔴 Error in getBanners: $e');
      return [];
    }
  }
}