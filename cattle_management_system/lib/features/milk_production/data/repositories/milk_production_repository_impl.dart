import '../../../../core/services/api_service.dart';
import '../../../cattle/data/models/cattle_model.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../domain/entities/milk_production_entry.dart';
import '../../domain/repositories/milk_production_repository.dart';

class MilkProductionRepositoryImpl implements MilkProductionRepository {
  final ApiService apiService;

  MilkProductionRepositoryImpl({required this.apiService});

  @override
  Future<List<MilkProductionEntry>> getMilkProductionByDate(
      DateTime date,
      ) async {
    final responses = await Future.wait([
      apiService.getDailyProductionReport(
        date: date.toIso8601String().split('T')[0],
      ),
      apiService.getCows(limit: 500),
      apiService.getBulls(limit: 500),
    ]);

    final response = responses[0] as Map<String, dynamic>;
    final cattleRegistry = [
      ...(responses[1] as List)
          .whereType<Map>()
          .map((item) => CattleModel.fromJson(Map<String, dynamic>.from(item))),
      ...(responses[2] as List)
          .whereType<Map>()
          .map((item) => CattleModel.fromJson(Map<String, dynamic>.from(item))),
    ];

    // Matches the "report" key seen in your backend logs
    final List<dynamic> reportData = response['report'] ?? [];

    return reportData.map((json) {
      final animalId = json['animalId']?.toString() ?? '';
      final matchedAnimal = _matchAnimal(cattleRegistry, animalId);
      return MilkProductionEntry(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        cattleId: animalId,
        cattleName: _resolveAnimalName(json, matchedAnimal),
        cattleGroup: matchedAnimal?.normalizedCowGroup,
        morningMilk: (json['morning'] ?? 0).toDouble(),
        eveningMilk: (json['evening'] ?? 0).toDouble(),
        morningFeed: (json['feed'] ?? 0).toDouble(),
        eveningFeed: 0.0,
        date: date,
      );
    }).toList();
  }

  Cattle? _matchAnimal(List<Cattle> registry, String animalId) {
    for (final animal in registry) {
      if (animal.id == animalId) return animal;
    }
    return null;
  }

  String _resolveAnimalName(dynamic rawJson, Cattle? matchedAnimal) {
    final json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : const <String, dynamic>{};
    final directName = [
      json['animalName'],
      json['name'],
      json['cowName'],
      json['cattleName'],
      matchedAnimal?.name,
    ]
        .map((value) => value?.toString().trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (directName.isNotEmpty) return directName;

    final animalId = json['animalId']?.toString() ?? '';
    if (animalId.length >= 4) {
      return 'Cow ${animalId.substring(0, 4)}';
    }
    return 'Unknown';
  }

  @override
  Future<List<dynamic>> getMilkHistoryForAnimal({
    required String animalId,
    required int month,
    required int year,
  }) async {
    final report = await apiService.getCowMonthlyReport(
      animalId: animalId,
      month: month,
      year: year,
    );
    final data = report['data'] ?? report;
    if (data is Map<String, dynamic>) {
      final dailyRecords = data['dailyRecords'];
      if (dailyRecords is List) {
        return dailyRecords;
      }
      final records = data['records'];
      if (records is List) {
        return records;
      }
      final items = data['items'];
      if (items is List) {
        return items;
      }
    }
    return const [];
  }
}
