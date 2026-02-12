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
    // فعلاً پیاده‌سازی نشده چون تمرکز روی SMS و Register است
    return Left(ServerFailure("Login method not implemented yet"));
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
      final userDto = await _remoteDataSource.verifyOtp(mobile, token, code);
      
      // ذخیره توکن
      await _prefs.setString('client_token', userDto.token);
      await _prefs.setString('client_name', "${userDto.firstName} ${userDto.lastName}");
      
      return Right(userDto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String firstName, String lastName, String mobile, String password) async {
    try {
      final userDto = await _remoteDataSource.register(firstName, lastName, mobile, password);
      
      // ذخیره توکن
      await _prefs.setString('client_token', userDto.token);
      await _prefs.setString('client_name', "${userDto.firstName} ${userDto.lastName}");
      
      return Right(userDto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}