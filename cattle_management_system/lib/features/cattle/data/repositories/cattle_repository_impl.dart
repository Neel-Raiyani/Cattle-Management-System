import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cattle.dart';
import '../../domain/repositories/cattle_repository.dart';
import '../datasources/cattle_local_data_source.dart';
import '../datasources/cattle_remote_data_source.dart';
import '../models/cattle_model.dart';

class CattleRepositoryImpl implements CattleRepository {
  final CattleRemoteDataSource remoteDataSource;
  final CattleLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CattleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  bool _isTerminalStatus(String status) {
    final normalized = status.toUpperCase();
    return normalized == 'SOLD' ||
        normalized == 'DEAD' ||
        normalized == 'DONATED';
  }

  @override
  Future<Either<Failure, List<Cattle>>> getAllCattle() async {
    final cachedCattle = await localDataSource.getLastCattleList();

    if (await networkInfo.isConnected) {
      try {
        final remoteCattle = await remoteDataSource.getAllCattle();
        final mergedById = <String, Cattle>{};

        for (final cattle in remoteCattle) {
          mergedById[cattle.id] = cattle;
        }

        for (final cattle in cachedCattle) {
          if (_isTerminalStatus(cattle.status)) {
            mergedById[cattle.id] = cattle;
          }
        }

        final mergedCattle = mergedById.values.toList();
        final cacheableCattle = mergedCattle
            .map(
              (cattle) => cattle is CattleModel
                  ? cattle
                  : CattleModel(
                      id: cattle.id,
                      tagNumber: cattle.tagNumber,
                      name: cattle.name,
                      breed: cattle.breed,
                      gender: cattle.gender,
                      dateOfBirth: cattle.dateOfBirth,
                      color: cattle.color,
                      weight: cattle.weight,
                      status: cattle.status,
                      imageUrl: cattle.imageUrl,
                      acquisitionType: cattle.acquisitionType,
                      isLactating: cattle.isLactating,
                      isHeifer: cattle.isHeifer,
                      isPregnant: cattle.isPregnant,
                      isDryOff: cattle.isDryOff,
                      isRetired: cattle.isRetired,
                      createdAt: cattle.createdAt,
                      updatedAt: cattle.updatedAt,
                      parity: cattle.parity,
                      lastDeliveryDate: cattle.lastDeliveryDate,
                      dailyMilkProduction: cattle.dailyMilkProduction,
                      serialNumber: cattle.serialNumber,
                      motherId: cattle.motherId,
                      fatherId: cattle.fatherId,
                      motherName: cattle.motherName,
                      fatherName: cattle.fatherName,
                      dateOfAdult: cattle.dateOfAdult,
                      deathReason: cattle.deathReason,
                      deathDate: cattle.deathDate,
                      cowGroup: cattle.cowGroup,
                      isHandicapped: cattle.isHandicapped,
                      handicapReason: cattle.handicapReason,
                      isUdderClosedFL: cattle.isUdderClosedFL,
                      isUdderClosedFR: cattle.isUdderClosedFR,
                      isUdderClosedBL: cattle.isUdderClosedBL,
                      isUdderClosedBR: cattle.isUdderClosedBR,
                      purchaseDate: cattle.purchaseDate,
                      purchasedFrom: cattle.purchasedFrom,
                      purchasePrice: cattle.purchasePrice,
                      ownerName: cattle.ownerName,
                      ownerMobile: cattle.ownerMobile,
                      retiredDate: cattle.retiredDate,
                      bullView: cattle.bullView,
                      motherMilk: cattle.motherMilk,
                      grandmotherMilk: cattle.grandmotherMilk,
                    ),
            )
            .toList();
        await localDataSource.cacheCattleList(cacheableCattle);
        return Right(mergedCattle);
      } on ServerException catch (e) {
        return cachedCattle.isNotEmpty
            ? Right(cachedCattle)
            : Left(ServerFailure(e.message));
      } catch (e) {
        return cachedCattle.isNotEmpty
            ? Right(cachedCattle)
            : Left(ServerFailure(e.toString()));
      }
    } else {
      return cachedCattle.isNotEmpty
          ? Right(cachedCattle)
          : Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Cattle>>> getCows() async {
    final cachedCattle = await localDataSource.getLastCattleList();
    final cachedCows = cachedCattle
        .where((c) => c.gender.toUpperCase().startsWith('F'))
        .toList();

    if (await networkInfo.isConnected) {
      try {
        final remoteCows = await remoteDataSource.getCows();
        // We merge/update the cache with new cows
        return Right(remoteCows);
      } on ServerException catch (e) {
        return cachedCows.isNotEmpty
            ? Right(cachedCows)
            : Left(ServerFailure(e.message));
      } catch (e) {
        return cachedCows.isNotEmpty
            ? Right(cachedCows)
            : Left(ServerFailure(e.toString()));
      }
    } else {
      return cachedCows.isNotEmpty
          ? Right(cachedCows)
          : Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Cattle>>> getBulls() async {
    final cachedCattle = await localDataSource.getLastCattleList();
    final cachedBulls = cachedCattle
        .where((c) => c.gender.toUpperCase().startsWith('M'))
        .toList();

    if (await networkInfo.isConnected) {
      try {
        final remoteBulls = await remoteDataSource.getBulls();
        return Right(remoteBulls);
      } on ServerException catch (e) {
        return cachedBulls.isNotEmpty
            ? Right(cachedBulls)
            : Left(ServerFailure(e.message));
      } catch (e) {
        return cachedBulls.isNotEmpty
            ? Right(cachedBulls)
            : Left(ServerFailure(e.toString()));
      }
    } else {
      return cachedBulls.isNotEmpty
          ? Right(cachedBulls)
          : Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Cattle>> getCattleById(String id) async {
    final cachedCattle = await localDataSource.getLastCattleList();
    final cached = cachedCattle.where((c) => c.id == id).toList();

    if (await networkInfo.isConnected) {
      try {
        final remoteCattle = await remoteDataSource.getCattleById(id);
        return Right(remoteCattle);
      } on ServerException catch (e) {
        return cached.isNotEmpty
            ? Right(cached.first)
            : Left(ServerFailure(e.message));
      } catch (e) {
        return cached.isNotEmpty
            ? Right(cached.first)
            : Left(ServerFailure(e.toString()));
      }
    } else {
      return cached.isNotEmpty
          ? Right(cached.first)
          : Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Cattle>> addCattle(Cattle cattle) async {
    if (await networkInfo.isConnected) {
      try {
        final newCattle = await remoteDataSource.addCattle(cattle);
        // Refresh full cache after add
        await getAllCattle();
        return Right(newCattle);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Cattle>> updateCattle(Cattle cattle) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedCattle = await remoteDataSource.updateCattle(cattle);
        // Refresh full cache after update
        await getAllCattle();
        return Right(updatedCattle);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCattle(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteCattle(id);
        // Refresh full cache after delete
        await getAllCattle();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
