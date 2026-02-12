import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  @override
  Future<Either<Failure, UserEntity>> login(String username, String password) async {
    return Left(ServerFailure("Login not implemented"));
  }

  @override
  Future<Either<Failure, String>> requestOtp(String mobile) async {
    try {
      final token = await _remoteDataSource.sendOtp(mobile);
      return Right(token);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String token, String code) async {
    try {
      final user = await _remoteDataSource.verifyOtp(mobile, token, code);
      await _prefs.setString('client_token', user.token);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String firstName, String lastName, String mobile, String password) async {
    try {
      final user = await _remoteDataSource.register(firstName, lastName, mobile, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}