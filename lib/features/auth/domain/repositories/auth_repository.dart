import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String username, String password);
  Future<Either<Failure, String>> requestOtp(String mobile);
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String token, String code);
  Future<Either<Failure, UserEntity>> register(String firstName, String lastName, String mobile, String password);
}