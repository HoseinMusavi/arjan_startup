import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // لاگین با ایمیل و پسورد
  Future<Either<Failure, UserEntity>> login(String username, String password);
  
  // درخواست رمز یکبار مصرف (بازگشت توکن موقت)
  Future<Either<Failure, String>> requestOtp(String mobile);
  
  // تایید رمز یکبار مصرف و دریافت اطلاعات کاربر
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String token, String code);
}