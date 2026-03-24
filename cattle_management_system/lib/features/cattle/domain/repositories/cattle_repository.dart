import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cattle.dart';

abstract class CattleRepository {
  Future<Either<Failure, List<Cattle>>> getAllCattle();
  Future<Either<Failure, List<Cattle>>> getCows();
  Future<Either<Failure, List<Cattle>>> getBulls();
  Future<Either<Failure, Cattle>> getCattleById(String id);
  Future<Either<Failure, Cattle>> addCattle(Cattle cattle);
  Future<Either<Failure, Cattle>> updateCattle(Cattle cattle);
  Future<Either<Failure, void>> deleteCattle(
    String id,
  ); // There might substitute with disposal/sell/death
}
