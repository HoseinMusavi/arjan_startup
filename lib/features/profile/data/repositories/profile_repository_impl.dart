import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/datasources/profile_remote_source.dart';
import '../../../profile/data/models/profile_dto.dart';
import '../../../profile/data/models/point_summary_dto.dart';
import '../../../profile/data/models/point_detail_dto.dart';
import '../../../profile/data/models/address_dto.dart';
import '../../../profile/data/models/notification_dto.dart';

/// پیاده‌سازی ریپازیتوری پروفایل
/// تمام خطاها را به Failure تبدیل کرده و با Either برمی‌گرداند
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  // ==================== پروفایل ====================
  @override
  Future<Either<Failure, ProfileDto>> getProfile({String? currentPage}) async {
    debugPrint('📡 [ProfileRepo] getProfile called');
    try {
      final result = await _remoteDataSource.getProfile(currentPage: currentPage);
      debugPrint('✅ [ProfileRepo] getProfile success');
      return Right(result);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] getProfile error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String firstName,
    required String lastName,
    required String contactPhone,
    required String emailAddress,
    String? currentPage,
  }) async {
    debugPrint('📡 [ProfileRepo] updateProfile called');
    try {
      await _remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        contactPhone: contactPhone,
        emailAddress: emailAddress,
        currentPage: currentPage,
      );
      debugPrint('✅ [ProfileRepo] updateProfile success');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] updateProfile error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? currentPage,
  }) async {
    debugPrint('📡 [ProfileRepo] changePassword called');
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
        currentPage: currentPage,
      );
      debugPrint('✅ [ProfileRepo] changePassword success');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] changePassword error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== کیف پول ====================
  @override
  Future<Either<Failure, List<PointSummaryDto>>> getPointSummary({String? currentPage}) async {
    debugPrint('📡 [ProfileRepo] getPointSummary called');
    try {
      final result = await _remoteDataSource.getPointSummary(currentPage: currentPage);
      debugPrint('✅ [ProfileRepo] getPointSummary success, count: ${result.length}');
      return Right(result);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] getPointSummary error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PointDetailDto>>> getPointDetails({
    required String pointType,
    String? currentPage,
  }) async {
    debugPrint('📡 [ProfileRepo] getPointDetails called for type: $pointType');
    try {
      final result = await _remoteDataSource.getPointDetails(
        pointType: pointType,
        currentPage: currentPage,
      );
      debugPrint('✅ [ProfileRepo] getPointDetails success, count: ${result.length}');
      return Right(result);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] getPointDetails error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== آدرس‌ها ====================
  @override
  Future<Either<Failure, List<AddressDto>>> getAddressList({
    String? pageAction,
    String? currentPage,
  }) async {
    debugPrint('📡 [ProfileRepo] getAddressList called');
    try {
      final result = await _remoteDataSource.getAddressList(
        pageAction: pageAction,
        currentPage: currentPage,
      );
      debugPrint('✅ [ProfileRepo] getAddressList success, count: ${result.length}');
      return Right(result);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] getAddressList error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAddress(Map<String, dynamic> addressData, {String? currentPage}) async {
    debugPrint('📡 [ProfileRepo] saveAddress called');
    try {
      await _remoteDataSource.saveAddress(addressData, currentPage: currentPage);
      debugPrint('✅ [ProfileRepo] saveAddress success');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] saveAddress error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress({required String id, String? currentPage}) async {
    debugPrint('📡 [ProfileRepo] deleteAddress called for id: $id');
    try {
      await _remoteDataSource.deleteAddress(id: id, currentPage: currentPage);
      debugPrint('✅ [ProfileRepo] deleteAddress success');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] deleteAddress error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getCountryList({String? currentPage}) async {
    debugPrint('📡 [ProfileRepo] getCountryList called');
    try {
      final result = await _remoteDataSource.getCountryList(currentPage: currentPage);
      debugPrint('✅ [ProfileRepo] getCountryList success, countries: ${result.keys}');
      return Right(result);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] getCountryList error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== اعلان‌ها ====================
  @override
  Future<Either<Failure, List<NotificationDto>>> getNotifications({String? currentPage}) async {
    debugPrint('📡 [ProfileRepo] getNotifications called');
    try {
      final result = await _remoteDataSource.getNotifications(currentPage: currentPage);
      debugPrint('✅ [ProfileRepo] getNotifications success, count: ${result.length}');
      return Right(result);
    } catch (e) {
      debugPrint('❌ [ProfileRepo] getNotifications error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}