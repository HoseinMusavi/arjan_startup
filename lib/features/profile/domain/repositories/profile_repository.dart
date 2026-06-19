import 'package:arjan_startup/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/profile_dto.dart';
import '../../data/models/point_summary_dto.dart';
import '../../data/models/point_detail_dto.dart';
import '../../data/models/address_dto.dart';
import '../../data/models/notification_dto.dart';

/// اینترفیس ریپازیتوری پروفایل
/// تمام متدهای مرتبط با مدیریت حساب کاربری، کیف پول، آدرس‌ها و اعلان‌ها
abstract class ProfileRepository {
  // ==================== پروفایل ====================
  Future<Either<Failure, ProfileDto>> getProfile({String? currentPage});
  Future<Either<Failure, void>> updateProfile({
    required String firstName,
    required String lastName,
    required String contactPhone,
    required String emailAddress,
    String? currentPage,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? currentPage,
  });

  // ==================== کیف پول ====================
  Future<Either<Failure, List<PointSummaryDto>>> getPointSummary({String? currentPage});
  Future<Either<Failure, List<PointDetailDto>>> getPointDetails({
    required String pointType,
    String? currentPage,
  });

  // ==================== آدرس‌ها ====================
  Future<Either<Failure, List<AddressDto>>> getAddressList({
    String? pageAction,
    String? currentPage,
  });
  Future<Either<Failure, void>> saveAddress(Map<String, dynamic> addressData, {String? currentPage});
  Future<Either<Failure, void>> deleteAddress({required String id, String? currentPage});
  Future<Either<Failure, Map<String, String>>> getCountryList({String? currentPage});

  // ==================== اعلان‌ها ====================
  Future<Either<Failure, List<NotificationDto>>> getNotifications({String? currentPage});
}