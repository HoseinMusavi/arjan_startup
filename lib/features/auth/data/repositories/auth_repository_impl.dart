import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;
  late final SessionService _sessionService;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs) {
    _sessionService = GetIt.instance<SessionService>();
  }

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
        await _sessionService.setUserToken(user.token);
        debugPrint("✅ [REPO] توکن در SharedPreferences و SessionService ذخیره شد");
        
        await _prefs.setString('user_first_name', user.firstName);
        await _prefs.setString('user_last_name', user.lastName);
        await _prefs.setString('user_phone', user.phone);
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> createAccount({
    required String firstName,
    required String lastName,
    required String mobile,
    required double lat,
    required double lng,
  }) async {
    debugPrint("📝 [REPO] درخواست ثبت‌نام کاربر: $firstName $lastName, شماره: $mobile");
    
    try {
      final result = await _remoteDataSource.createAccount(
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        lat: lat,
        lng: lng,
      );
      
      debugPrint("✅ [REPO] ثبت‌نام اولیه موفق");
      debugPrint("📱 [REPO] customer_token: ${result['customer_token']}");
      
      return Right(result);
      
    } on ServerException catch (e) {
      debugPrint("❌ [REPO] خطای سرور در createAccount: ${e.message} (code: ${e.code})");
      
      if (e.message.contains('تکرار') || e.message.contains('duplicate')) {
        return Left(ServerFailure("این شماره موبایل قبلاً ثبت نام کرده است"));
      }
      
      return Left(ServerFailure(e.message));
      
    } catch (e) {
      debugPrint("❌ [REPO] خطای غیرمنتظره در createAccount: $e");
      return Left(ServerFailure("خطا در ثبت‌نام. لطفاً مجدداً تلاش کنید"));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyAccount({
    required String mobile,
    required String otp,
    required String customerToken,
  }) async {
    debugPrint("🔐 [REPO] تایید ثبت‌نام برای: $mobile");
    debugPrint("   - customerToken: $customerToken");
    debugPrint("   - otp: $otp");
    
    try {
      final user = await _remoteDataSource.verifyAccount(
        mobile: mobile,
        otp: otp,
        customerToken: customerToken,
      );
      
      debugPrint("✅ [REPO] تایید ثبت‌نام موفق - کاربر: ${user.firstName} ${user.lastName}");
      
      if (user.token.isNotEmpty && user.token != 'null') {
        await _prefs.setString('client_token', user.token);
        await _prefs.setString('user_token', user.token);
        await _sessionService.setUserToken(user.token);
        debugPrint("✅ [REPO] توکن در SharedPreferences و SessionService ذخیره شد");
        
        await _prefs.setString('user_first_name', user.firstName);
        await _prefs.setString('user_last_name', user.lastName);
        await _prefs.setString('user_phone', user.phone);
        
        return Right(user);
      } else {
        debugPrint("⚠️ [REPO] توکن خالی یا نامعتبر است!");
        return Left(ServerFailure("توکن دریافتی نامعتبر است"));
      }
      
    } on ServerException catch (e) {
      debugPrint("❌ [REPO] خطای سرور در verifyAccount: ${e.message} (code: ${e.code})");
      
      if (e.message.contains('تایید') || e.message.contains('فعال')) {
        return Left(ServerFailure("حساب کاربری شما نیاز به تایید دارد. لطفاً به پنل ادمین مراجعه کنید"));
      }
      
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint("❌ [REPO] خطای غیرمنتظره در verifyAccount: $e");
      return Left(ServerFailure("خطا در تایید ثبت‌نام"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // ✅ فقط توکن‌ها را پاک کن، device_uiid را حفظ کن
      await _prefs.remove('client_token');
      await _prefs.remove('user_token');
      await _prefs.remove('user_first_name');
      await _prefs.remove('user_last_name');
      await _prefs.remove('user_phone');
      
      debugPrint("✅ [REPO] خروج از حساب - توکن حذف شد");
      return const Right(null);
    } catch (e) {
      debugPrint("❌ [REPO] خطا در خروج: $e");
      return Left(CacheFailure("خطا در خروج"));
    }
  }
}