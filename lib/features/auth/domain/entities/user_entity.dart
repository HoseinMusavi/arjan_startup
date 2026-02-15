import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String token;
  final String firstName;
  final String lastName;
  final String phone;

  const UserEntity({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  List<Object?> get props => [token, firstName, lastName, phone];
}