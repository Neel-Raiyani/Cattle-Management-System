import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String mobile, String password);
  Future<Either<Failure, void>> register(
    String name,
    String mobile,
    String password,
    String confirmPassword,
    String city,
    String gaushalaName,
    int totalCattle,
  );
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<Either<Failure, String>> getUserName();
}
