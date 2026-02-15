import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // ارسال درخواست OTP (خروجی: توکن موقت برای تایید)
  Future<Either<Failure, String>> requestOtp(String mobile);

  // تایید OTP (خروجی: اطلاعات کاربر لاگین شده)
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String otp, String token);

  // خروج از حساب
  Future<Either<Failure, void>> logout();
}