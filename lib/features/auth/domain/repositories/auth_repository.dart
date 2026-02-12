import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // لاگین با ایمیل و پسورد (فعلاً استفاده نمی‌شود اما برای آینده هست)
  Future<Either<Failure, UserEntity>> login(String username, String password);
  
  // درخواست رمز پیامکی
  Future<Either<Failure, String>> requestOtp(String mobile);
  
  // تایید رمز پیامکی
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String token, String code);
  
  // ثبت نام کاربر جدید
  Future<Either<Failure, UserEntity>> register(String firstName, String lastName, String mobile, String password);
}