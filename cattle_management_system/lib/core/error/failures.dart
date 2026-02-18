import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(String message, [int? code]) : super(message, code);
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Authentication Failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, [int? code]) : super(message, code);
}

/// Permission Failure
class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

/// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Timeout Failure
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message) : super(message);
}

/// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
