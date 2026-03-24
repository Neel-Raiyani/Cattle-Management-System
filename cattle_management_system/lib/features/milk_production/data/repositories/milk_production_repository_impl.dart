import '../../../../core/services/api_service.dart';
import '../../domain/entities/milk_production_entry.dart';
import '../../domain/repositories/milk_production_repository.dart';

class MilkProductionRepositoryImpl implements MilkProductionRepository {
  final ApiService apiService;

  MilkProductionRepositoryImpl({required this.apiService});

  @override
  Future<List<MilkProductionEntry>> getMilkProductionByDate(
      DateTime date,
      ) async {
    final response = await apiService.getDailyProductionReport(
      date: date.toIso8601String().split('T')[0],
    );

    // Matches the "report" key seen in your backend logs
    final List<dynamic> reportData = response['report'] ?? [];

    return reportData.map((json) {
      return MilkProductionEntry(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        cattleId: json['animalId']?.toString() ?? '',
        // Placeholder name until matched in the Bloc
        cattleName: 'Cow ${json['animalId'].toString().substring(0, 4)}',
        morningMilk: (json['morning'] ?? 0).toDouble(),
        eveningMilk: (json['evening'] ?? 0).toDouble(),
        morningFeed: (json['feed'] ?? 0).toDouble(),
        eveningFeed: 0.0,
        date: date,
      );
    }).toList();
  }

  @override
  Future<List<dynamic>> getMilkHistoryForAnimal({
    required String animalId,
    required int month,
    required int year,
  }) async {
    return await apiService.getMilkHistoryForAnimal(
      animalId: animalId,
      month: month,
      year: year,
    );
  }
}