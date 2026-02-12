import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  // اینجا به جای DioClient مستقیم، از RemoteDataSource استفاده می‌کنیم تا معماری تمیز بماند
  // اما چون در مرحله قبل در فایل ServiceLocator هنوز DataSource را نساختیم، 
  // فعلا موقتا اینجا کدهای DataSource را فراخوانی می‌کنیم یا باید ServiceLocator را آپدیت کنیم.
  // برای راحتی شما و جلوگیری از گیج شدن، من اینجا فرض میکنم که شما 
  // AuthRemoteDataSourceImpl را ساخته‌اید (فایل بالا).
  
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  @override
  Future<Either<Failure, UserEntity>> login(String username, String password) async {
    // این متد برای لاگین معمولی (ایمیل/پسورد) است که فعلا استفاده نمی‌شود اما ساختیمش
    // چون در AuthRemoteDataSource متد login مستقیم نداریم (پرایوت است)، فعلا خالی میگذاریم
    // یا میتوانید آن متد _loginAfterReset را پابلیک کنید.
    // اما چون الان تمرکز روی OTP است، فعلا این را نادیده میگیریم.
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
      
      // ذخیره توکن برای استفاده‌های بعدی
      if (userDto is UserDto) {
         await _prefs.setString('client_token', userDto.token);
         await _prefs.setString('client_name', "${userDto.firstName} ${userDto.lastName}");
      }
      
      return Right(userDto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}