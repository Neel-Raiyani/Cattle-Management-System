import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String mobile;
  final String password;

  const LoginEvent({required this.mobile, required this.password});

  @override
  List<Object> get props => [mobile, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String mobile;
  final String password;
  final String confirmPassword;
  final String city;
  final String gaushalaName;
  final int totalCattle;

  const RegisterEvent({
    required this.name,
    required this.mobile,
    required this.password,
    required this.confirmPassword,
    required this.city,
    required this.gaushalaName,
    required this.totalCattle,
  });

  @override
  List<Object> get props => [
    name,
    mobile,
    password,
    confirmPassword,
    city,
    gaushalaName,
    totalCattle,
  ];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
