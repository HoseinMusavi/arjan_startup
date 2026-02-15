import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      final token = await _remoteDataSource.requestOtp(mobile);
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("خطای غیرمنتظره در ارسال کد"));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String mobile, String otp, String token) async {
    try {
      final user = await _remoteDataSource.verifyOtp(mobile, otp, token);
      
      // ذخیره توکن واقعی (که با 9htac شروع می‌شود)
      if (user.token.isNotEmpty) {
        await _prefs.setString('client_token', user.token);
      }
      
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("خطا در تایید کد"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _prefs.remove('client_token');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure("خطا در خروج"));
    }
  }
}