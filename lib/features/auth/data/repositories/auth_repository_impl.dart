import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  @override
  Future<Either<Failure, String>> requestOtp(String mobile) async {
    debugPrint("🔐 [REPO] درخواست OTP برای: $mobile");
    try {
      final token = await _remoteDataSource.requestOtp(mobile);
      debugPrint("✅ [REPO] OTP ارسال شد - token: $token");
      return Right(token);
    } on ServerException catch (e) {
      debugPrint("❌ [REPO] خطای سرور در requestOtp: ${e.message} (code: ${e.code})");
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint("❌ [REPO] خطای غیرمنتظره در requestOtp: $e");
      return Left(ServerFailure("خطای غیرمنتظره در ارسال کد"));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String otp, String token) async {
    debugPrint("🔐 [REPO] تایید OTP برای: $mobile");
    debugPrint("   - otp: $otp");
    debugPrint("   - token: $token");
    
    try {
      final user = await _remoteDataSource.verifyOtp(mobile, otp, token);
      
      debugPrint("📝 [REPO] دریافت اطلاعات کاربر: token=${user.token.substring(0, user.token.length > 10 ? 10 : user.token.length)}..., name=${user.firstName}");
      
      if (user.token.isNotEmpty && user.token != 'null') {
        await _prefs.setString('client_token', user.token);
        debugPrint("✅ [REPO] توکن در SharedPreferences ذخیره شد");
      } else {
        debugPrint("⚠️ [REPO] توکن خالی یا نامعتبر است!");
      }
      
      return Right(user);
    } on ServerException catch (e) {
      debugPrint("❌ [REPO] خطای سرور در verifyOtp: ${e.message} (code: ${e.code})");
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint("❌ [REPO] خطای غیرمنتظره در verifyOtp: $e");
      return Left(ServerFailure("خطا در تایید کد"));
    }
  }

  // ✅ اضافه شده: ثبت‌نام کاربر جدید
  @override
  Future<Either<Failure, UserEntity>> createAccount({
    required String firstName,
    required String lastName,
    required String mobile,
    required double lat,
    required double lng,
  }) async {
    debugPrint("📝 [REPO] درخواست ثبت‌نام کاربر: $firstName $lastName, شماره: $mobile");
    try {
      final user = await _remoteDataSource.createAccount(
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        lat: lat,
        lng: lng,
      );
      
      debugPrint("📝 [REPO] ثبت‌نام موفق - کاربر: ${user.firstName}");
      
      if (user.token.isNotEmpty && user.token != 'null') {
        await _prefs.setString('client_token', user.token);
        debugPrint("✅ [REPO] توکن در SharedPreferences ذخیره شد");
      }
      
      return Right(user);
    } on ServerException catch (e) {
      debugPrint("❌ [REPO] خطای سرور در createAccount: ${e.message} (code: ${e.code})");
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint("❌ [REPO] خطای غیرمنتظره در createAccount: $e");
      return Left(ServerFailure("خطا در ثبت‌نام"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _prefs.remove('client_token');
      debugPrint("✅ [REPO] خروج از حساب - توکن حذف شد");
      return const Right(null);
    } catch (e) {
      debugPrint("❌ [REPO] خطا در خروج: $e");
      return Left(CacheFailure("خطا در خروج"));
    }
  }
}