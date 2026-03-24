import '../entities/milk_production_entry.dart';

abstract class MilkProductionRepository {
  Future<List<MilkProductionEntry>> getMilkProductionByDate(DateTime date);
  Future<List<dynamic>> getMilkHistoryForAnimal({
    required String animalId,
    required int month,
    required int year,
  });
}
