import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/profile_dto.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileDto>> getProfile();
}