import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> requestOtp(String mobile);
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String otp, String token);
  Future<Either<Failure, Map<String, dynamic>>> createAccount({
    required String firstName,
    required String lastName,
    required String mobile,
    required double lat,
    required double lng,
  });
  Future<Either<Failure, UserEntity>> verifyAccount({
    required String mobile,
    required String otp,
    required String customerToken,
  });
  Future<Either<Failure, void>> logout();
}