import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';

/// Centralized API service for all backend calls.
/// Each method maps directly to a backend endpoint.
class ApiService {
  final ApiClient apiClient;
  _VisibleAnimalRegistry? _visibleAnimalRegistryCache;
  DateTime? _visibleAnimalRegistryCachedAt;
  static const Duration _visibleAnimalRegistryTtl = Duration(minutes: 2);

  ApiService({required this.apiClient});

  // ─────────────────────────────────────────────────────────────
  // AUTH / STAFF SERVICE
  // ─────────────────────────────────────────────────────────────

  /// GET /api/auth/staff — Fetch all staff for the gaushala (all roles).
  /// Response: { "success": true, "staff": [...], "total": N }
  Future<List<Map<String, dynamic>>> getAllStaff() async {
    final data = await _get('/api/auth/staff', {});
    // Backend returns { "staff": [...] } — check 'staff' first, then 'data', then raw list
    final List<dynamic> staff = data is List
        ? data
        : (data['staff'] as List? ?? data['data'] as List? ?? []);
    return staff
        .whereType<Map<String, dynamic>>()
        .map(
          (s) => {
            'id': s['_id']?.toString() ?? s['id']?.toString() ?? '',
            'name':
                s['name']?.toString() ?? s['userName']?.toString() ?? 'Unknown',
            'mobileNumber': s['mobileNumber']?.toString() ?? '',
            'city': s['city']?.toString() ?? '',
            'role': s['role']?.toString() ?? '',
          },
        )
        .toList();
  }

  /// POST /api/auth/staff — Add a new staff member.
  /// Fields: mobileNumber (required), name (required), city, role (enum: OWNER|MANAGER|STAFF|VETERINARIAN)
  Future<Map<String, dynamic>> addStaff({
    required String mobileNumber,
    required String name,
    required String role, // 'OWNER' | 'MANAGER' | 'STAFF' | 'VETERINARIAN'
    String? city,
  }) async {
    return await _post('/api/auth/staff', {
      'mobileNumber': mobileNumber,
      'name': name,
      'role': role,
      if (city != null && city.isNotEmpty) 'city': city,
    });
  }

  /// GET /api/auth/staff — Fetch all staff filtered to VETERINARIAN role.
  /// Response: { "success": true, "staff": [...], "total": N }
  Future<List<Map<String, dynamic>>> getVeterinarians() async {
    final data = await _get('/api/auth/staff', {});
    final List<dynamic> staff = data is List
        ? data
        : (data['staff'] as List? ?? data['data'] as List? ?? []);
    return staff
        .whereType<Map<String, dynamic>>()
        .where(
          (s) => (s['role'] ?? '').toString().toUpperCase() == 'VETERINARIAN',
        )
        .map(
          (s) => {
            'id': s['_id']?.toString() ?? s['id']?.toString() ?? '',
            'name':
                s['name']?.toString() ?? s['userName']?.toString() ?? 'Unknown',
            'mobileNumber': s['mobileNumber']?.toString() ?? '',
          },
        )
        .where((s) => s['id']!.isNotEmpty)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────
  // ANIMAL SERVICE
  // ─────────────────────────────────────────────────────────────

  /// POST /api/animal/death — Records death and marks animal as DEAD
  Future<Map<String, dynamic>> recordDeath({
    required String animalId,
    required DateTime dateOfDeath,
    required String reason,
    String? lastPhotoUrl,
  }) async {
    return await _post('/api/animal/death', {
      'animalId': animalId,
      'dateOfDeath': dateOfDeath.toIso8601String(),
      'reason': reason,
      if (lastPhotoUrl != null) 'lastPhotoUrl': lastPhotoUrl,
    });
  }

  /// POST /api/animal/sell — Records sale and marks animal as SOLD
  Future<Map<String, dynamic>> recordSell({
    required String animalId,
    required String buyer,
    required String mobileNumber,
    required double amount,
    String? city,
    String? referenceBy,
    String? photoUrl,
    DateTime? soldAt,
  }) async {
    return await _post('/api/animal/sell', {
      'animalId': animalId,
      'buyer': buyer,
      'mobileNumber': mobileNumber,
      'amount': amount,
      if (city != null) 'city': city,
      if (referenceBy != null) 'referenceBy': referenceBy,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (soldAt != null) 'soldAt': soldAt.toIso8601String(),
    });
  }

  /// POST /api/animal/donation — Records donation and marks animal as DONATED
  Future<Map<String, dynamic>> recordDonation({
    required String animalId,
    required String donatedTo,
    required String mobileNumber,
    String? city,
    String? referenceBy,
    String? photoUrl,
    DateTime? donatedAt,
  }) async {
    return await _post('/api/animal/donation', {
      'animalId': animalId,
      'donatedTo': donatedTo,
      'mobileNumber': mobileNumber,
      if (city != null) 'city': city,
      if (referenceBy != null) 'referenceBy': referenceBy,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (donatedAt != null) 'donatedAt': donatedAt.toIso8601String(),
    });
  }

  /// GET /api/animal/cows — Fetch all cows
  Future<List<dynamic>> getCows({int limit = 200, int page = 1}) async {
    final data = await _get('/api/animal/cows', {
      'limit': limit.toString(),
      'page': page.toString(),
    });
    final items = _extractList(
      data,
      primaryKeys: const ['cows', 'data', 'items', 'list'],
    );
    return items.map(_normalizeAnimalSummaryItem).toList();
  }

  /// GET /api/animal/bulls — Fetch all bulls
  Future<List<dynamic>> getBulls({int limit = 200, int page = 1}) async {
    final data = await _get('/api/animal/bulls', {
      'limit': limit.toString(),
      'page': page.toString(),
    });
    final items = _extractList(
      data,
      primaryKeys: const ['bulls', 'data', 'items', 'list'],
    );
    return items.map(_normalizeAnimalSummaryItem).toList();
  }

  /// GET /api/animal/reports/export/bulls — Bull report/export list
  Future<List<dynamic>> getBullReportExport() async {
    final data = await _get('/api/animal/reports/export/bulls', {});
    final items = _extractList(
      data,
      primaryKeys: const [
        'bulls',
        'data',
        'items',
        'list',
        'rows',
        'records',
      ],
    );
    return items.map(_normalizeAnimalSummaryItem).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // BREEDING SERVICE — HEAT RECORDS
  // ─────────────────────────────────────────────────────────────

  /// POST /api/breeding/heat — Record heat observation
  Future<Map<String, dynamic>> recordHeat({
    required String animalId,
    required DateTime date,
    required String breedingType, // 'NATURAL' or 'AI'
    String? bullId,
  }) async {
    return await _post('/api/breeding/heat', {
      'animalId': animalId,
      'date': date.toIso8601String(),
      'breedingType': breedingType,
      if (bullId != null) 'bullId': bullId,
    });
  }

  /// GET /api/breeding/heat?animalId={id} — Fetch heat history for an animal
  Future<List<dynamic>> getHeatHistory({required String animalId}) async {
    final data = await _get('/api/breeding/heat', {'animalId': animalId});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/breeding/heat/eligible — Animals eligible for heat recording
  Future<List<dynamic>> getHeatEligibleAnimals() async {
    final data = await _get('/api/breeding/heat/eligible', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/breeding/reports/heat — Heat record report
  Future<List<dynamic>> getHeatReport({
    String? animalId,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (animalId != null) params['animalId'] = animalId;
    if (from != null) params['from'] = from.toIso8601String().split('T')[0];
    if (to != null) params['to'] = to.toIso8601String().split('T')[0];
    final data = await _get('/api/breeding/reports/heat', params);
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// DELETE /api/breeding/heat/{id} — Delete heat record by ID (path param)
  /// The gaushala-id header is added automatically by the ApiClient interceptor.
  Future<Map<String, dynamic>> deleteHeatRecord({required String id}) async {
    if (id.isNotEmpty && id != 'null') {
      return await _delete('/api/breeding/heat/$id', {});
    } else {
      throw ServerException('Cannot delete: heat record ID is missing.', 400);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BREEDING SERVICE — DRY-OFF
  // ─────────────────────────────────────────────────────────────

  /// POST /api/breeding/dry-off — Mark animal as dry
  Future<Map<String, dynamic>> recordDryOff({
    required String animalId,
    required DateTime date,
    required String reason, // 'ILLNESS' | 'LOW_YIELD' | 'MEDICATED' | 'OTHER'
    String? remarks,
  }) async {
    return await _post('/api/breeding/dry-off', {
      'animalId': animalId,
      'date': date.toIso8601String(),
      'reason': reason,
      if (remarks != null) 'remarks': remarks,
    });
  }

  /// GET /api/breeding/dry-off/eligible
  Future<List<dynamic>> getDryOffEligibleAnimals() async {
    final data = await _get('/api/breeding/dry-off/eligible', {});
    return _extractList(
      data,
      primaryKeys: const ['data', 'animals', 'items', 'list'],
    );
  }

  /// GET /api/breeding/dry-off?animalId=...
  Future<List<dynamic>> getDryOffReport({required String animalId}) async {
    final data = await _get('/api/breeding/dry-off', {'animalId': animalId});
    return _extractList(
      data,
      primaryKeys: const ['data', 'records', 'history', 'items', 'list'],
    );
  }

  /// PATCH /api/breeding/dry-off/{id}
  Future<Map<String, dynamic>> updateDryOff({
    required String id,
    required String animalId,
    required DateTime date,
    required String reason,
    String? remarks,
  }) async {
    return await _patch('/api/breeding/dry-off/$id', {
      'animalId': animalId,
      'date': date.toIso8601String(),
      'reason': reason,
      if (remarks != null) 'remarks': remarks,
    });
  }

  /// DELETE /api/breeding/dry-off/{id}
  Future<Map<String, dynamic>> deleteDryOff({required String id}) async {
    return await _delete('/api/breeding/dry-off/$id', {});
  }

  // ─────────────────────────────────────────────────────────────
  // BREEDING SERVICE — CONCEPTION JOURNEY
  // ─────────────────────────────────────────────────────────────

  /// POST /api/breeding/journey/initiate
  Future<Map<String, dynamic>> initiatePregnancy({
    required String animalId,
    required DateTime conceiveDate,
    required String pregnancyType, // 'NATURAL' or 'AI'
  }) async {
    return await _post('/api/breeding/journey/initiate', {
      'animalId': animalId,
      'conceiveDate': conceiveDate.toIso8601String(),
      'pregnancyType': pregnancyType,
    });
  }

  /// GET /api/breeding/journey/list
  Future<List<dynamic>> getActiveJourneys() async {
    final data = await _get('/api/breeding/journey/list', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// DELETE /api/breeding/journey/{id}
  Future<Map<String, dynamic>> deleteJourney({required String id}) async {
    return await _delete('/api/breeding/journey/$id', {});
  }

  /// PATCH /api/breeding/journey/{id}/dry-off
  Future<Map<String, dynamic>> markJourneyDryOff({
    required String id,
    required DateTime dryOffDate,
  }) async {
    return await _patch('/api/breeding/journey/$id/dry-off', {
      'dryOffDate': dryOffDate.toIso8601String(),
    });
  }

  /// PATCH /api/breeding/journey/{id}/deliver
  Future<Map<String, dynamic>> deliverJourney({
    required String id,
    required DateTime deliveryDate,
    required String calfStatus,
    required String calfGender,
    String? calfName,
    String? calfTagNumber,
    String? calfBreed,
    String? calfGroup,
    String? calfAppearance,
    double? calfWeight,
  }) async {
    return await _patch('/api/breeding/journey/$id/deliver', {
      'deliveryDate': deliveryDate.toIso8601String(),
      'calfStatus': calfStatus,
      'calfGender': calfGender,
      if (calfName != null && calfName.isNotEmpty) 'calfName': calfName,
      if (calfTagNumber != null && calfTagNumber.isNotEmpty)
        'calfTagNumber': calfTagNumber,
      if (calfBreed != null && calfBreed.isNotEmpty) 'calfBreed': calfBreed,
      if (calfGroup != null && calfGroup.isNotEmpty) 'calfGroup': calfGroup,
      if (calfAppearance != null && calfAppearance.isNotEmpty)
        'calfAppearance': calfAppearance,
      if (calfWeight != null) 'calfWeight': calfWeight,
    });
  }

  /// GET /api/breeding/reports/pregnancy
  Future<List<dynamic>> getPregnancyReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from.toIso8601String().split('T')[0];
    if (to != null) params['to'] = to.toIso8601String().split('T')[0];
    final data = await _get('/api/breeding/reports/pregnancy', params);
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/breeding/reports/delivery
  Future<List<dynamic>> getDeliveryReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from.toIso8601String().split('T')[0];
    if (to != null) params['to'] = to.toIso8601String().split('T')[0];
    final data = await _get('/api/breeding/reports/delivery', params);
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/breeding/reports/parity/dropdown
  Future<List<dynamic>> getParityAnimalsDropdown() async {
    final data = await _get('/api/breeding/reports/parity/dropdown', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/breeding/parity/{animalId}
  Future<List<dynamic>> getBreedingParityReport({
    required String animalId,
  }) async {
    final data = await _get('/api/breeding/parity/$animalId', {});
    return _extractList(
      data,
      primaryKeys: const ['data', 'items', 'parities', 'records', 'list'],
    );
  }

  /// GET /api/breeding/journey/eligible-cows
  Future<List<dynamic>> getEligibleCowsForJourney() async {
    final data = await _get('/api/breeding/journey/eligible-cows', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/breeding/bulls/eligible
  Future<List<dynamic>> getEligibleBulls() async {
    final data = await _get('/api/breeding/bulls/eligible', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  // ─────────────────────────────────────────────────────────────
  // HEALTH SERVICE — DISEASES & VACCINES MASTER
  // ─────────────────────────────────────────────────────────────

  /// GET /api/health/master/diseases
  Future<List<dynamic>> getDiseases() async {
    final data = await _get('/api/health/master/diseases', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// POST /api/health/master/diseases
  Future<Map<String, dynamic>> addDisease({required String name}) async {
    return await _post('/api/health/master/diseases', {'name': name});
  }

  /// GET /api/health/master/vaccines
  Future<List<dynamic>> getVaccines() async {
    final data = await _get('/api/health/master/vaccines', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// POST /api/health/master/vaccines
  Future<Map<String, dynamic>> addVaccine({required String name}) async {
    return await _post('/api/health/master/vaccines', {'name': name});
  }

  // ─────────────────────────────────────────────────────────────
  // HEALTH SERVICE — MEDICAL RECORDS
  // ─────────────────────────────────────────────────────────────

  /// POST /api/health/medical
  Future<Map<String, dynamic>> addMedicalRecord({
    required String animalId,
    required String visitType, // 'ILLNESS' | 'CHECKUP'
    required DateTime visitDate,
    required String medicalStatus, // 'SICK' | 'HEALTHY'
    String? diseaseId,
    String? vetId,
    String? visitNumber,
    String? symptoms,
    String? treatment,
  }) async {
    return await _post('/api/health/medical', {
      'animalId': animalId,
      'visitType': visitType,
      'visitDate': visitDate.toIso8601String(),
      'medicalStatus': medicalStatus,
      if (diseaseId != null) 'diseaseId': diseaseId,
      if (vetId != null) 'vetId': vetId,
      if (visitNumber != null) 'visitNumber': visitNumber,
      if (symptoms != null) 'symptoms': symptoms,
      if (treatment != null) 'treatment': treatment,
    });
  }

  /// GET /api/health/reports/medical — Fetch medical records report
  /// (The backend has no general GET /api/health/medical list endpoint;
  ///  the report endpoint at /reports/medical serves as the list.)
  Future<List<dynamic>> getMedicalHistory({String? animalId}) async {
    final params = <String, dynamic>{};
    if (animalId != null) params['animalId'] = animalId;

    final data = await _get('/api/health/reports/medical', params);
    final records = _extractList(
      data,
      primaryKeys: const ['data', 'records', 'items', 'list'],
    );
    return await _filterRecordsForVisibleAnimals(records);
  }

  // ─────────────────────────────────────────────────────────────
  // HEALTH SERVICE — VACCINATION RECORDS
  // ─────────────────────────────────────────────────────────────

  /// POST /api/health/vaccination
  Future<Map<String, dynamic>> addVaccinationRecord({
    required String animalId,
    required DateTime doseDate,
    required String doseType, // 'FIRST' | 'BOOSTER' | 'REPEAT'
    required String vaccineId,
    String? remark,
  }) async {
    return await _post('/api/health/vaccination', {
      'animalId': animalId,
      'doseDate': doseDate.toIso8601String(),
      'doseType': doseType,
      'vaccineId': vaccineId,
      if (remark != null) 'remark': remark,
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ANIMAL GROUPS
  // ─────────────────────────────────────────────────────────────
  /// GET /api/animal/categories — Fetch all animal categories
  Future<List<dynamic>> getAnimalCategories() async {
    final data = await _get('/api/animal/categories', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/animal/groups — Fetch all cow groups
  Future<List<dynamic>> getCowGroups() async {
    final data = await _get('/api/animal/groups', {});
    return data is List
        ? data
        : (data['groups'] as List? ?? data['data'] as List? ?? []);
  }

  /// GET /api/animal/breeds — Fetch available cow breeds
  Future<List<String>> getBreeds() async {
    final List<String> fallbackBreeds = [
      'Gir',
      'Sahiwal',
      'Red_Sindhi',
      'Tharparkar',
      'Kankrej',
      'Rathi',
      'Punganur',
      'Badri',
      'Hallikar',
      'Kangayam',
      'Hariana',
      'Mewati',
      'Nagori',
      'Nimadi',
      'Malvi',
      'Kherigarh',
      'Amritmahal',
      'Umblachery',
      'Pulikulam',
      'Bargur',
      'Ongole',
      'Red_Kandhari',
      'Gaolao',
      'Gangatiri',
      'Siri',
    ];

    try {
      final data = await _get('/api/animal/breeds', {});
      debugPrint('[API] breeds raw response: $data');

      List<String> results = [];
      if (data is List) {
        results = data.map((e) => e.toString()).toList();
      } else if (data is Map) {
        if (data.containsKey('breeds') && data['breeds'] is List) {
          results = (data['breeds'] as List).map((e) => e.toString()).toList();
        } else if (data.containsKey('data')) {
          final innerData = data['data'];
          if (innerData is List) {
            results = innerData.map((e) => e.toString()).toList();
          } else if (innerData is Map && innerData.containsKey('breeds')) {
            results = (innerData['breeds'] as List)
                .map((e) => e.toString())
                .toList();
          }
        }
      }

      if (results.isNotEmpty) return results;
    } catch (e) {
      debugPrint('[API] Error in getBreeds: $e');
    }

    // Return fallback breeds if API fails or returns empty
    return fallbackBreeds;
  }

  Future<Map<String, dynamic>> addCowGroup(String name) async {
    return await _post('/api/animal/groups', {'name': name});
  }

  Future<Map<String, dynamic>> updateCowGroup(String id, String name) async {
    return await _patch('/api/animal/groups/$id', {'name': name});
  }

  Future<Map<String, dynamic>> deleteCowGroup(String id) async {
    return await _delete('/api/animal/groups/$id', {});
  }

  /// GET /api/health/reports/vaccine — Fetch vaccination records report
  /// The current backend exposes per-animal timelines at
  /// /api/health/vaccination/animal/{animalId}, so global history is built by
  /// aggregating those records across animals.
  Future<List<dynamic>> getVaccinationHistory({
    String? animalId,
    String? vaccineId,
    DateTime? from,
    DateTime? to,
  }) async {
    if (animalId != null && animalId.isNotEmpty) {
      final data = await _get('/api/health/vaccination/animal/$animalId', {});
      final records = _extractList(
        data,
        primaryKeys: const ['data', 'records', 'items', 'list'],
      );
      return (await _filterRecordsForVisibleAnimals(
        records.map((record) => _normalizeVaccinationRecord(record)).toList(),
      ))
          .toList();
    }

    final cows = await getCows(limit: 500);
    final bulls = await getBulls(limit: 500);
    final allAnimals = [
      ...cows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      ...bulls.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
    ];

    final normalized = <Map<String, dynamic>>[];
    for (final animal in allAnimals) {
      final currentAnimalId =
          (animal['id'] ?? animal['_id'] ?? '').toString().trim();
      if (currentAnimalId.isEmpty) continue;

      final data = await _get(
        '/api/health/vaccination/animal/$currentAnimalId',
        {},
      );
      final records = _extractList(
        data,
        primaryKeys: const ['data', 'records', 'items', 'list'],
      );
      normalized.addAll(
        records.map(
          (record) => _normalizeVaccinationRecord(record, animal: animal),
        ),
      );
    }

    bool matchesFilter(Map<String, dynamic> record) {
      if (vaccineId != null && vaccineId.isNotEmpty) {
        final recordVaccineId = (() {
          final vaccine = record['vaccine'];
          if (vaccine is Map) {
            return (vaccine['id'] ?? vaccine['_id'] ?? '').toString();
          }
          final vaccineRef = record['vaccineId'];
          if (vaccineRef is Map) {
            return (vaccineRef['id'] ?? vaccineRef['_id'] ?? '').toString();
          }
          return vaccineRef?.toString() ?? '';
        })();
        if (recordVaccineId != vaccineId) return false;
      }

      if (from != null || to != null) {
        final rawDate =
            record['doseDate'] ?? record['date'] ?? record['createdAt'];
        final parsed = rawDate != null
            ? DateTime.tryParse(rawDate.toString())?.toLocal()
            : null;
        if (parsed == null) return false;

        final eventDate = DateTime(parsed.year, parsed.month, parsed.day);
        if (from != null) {
          final start = DateTime(from.year, from.month, from.day);
          if (eventDate.isBefore(start)) return false;
        }
        if (to != null) {
          final end = DateTime(to.year, to.month, to.day);
          if (eventDate.isAfter(end)) return false;
        }
      }

      return true;
    }

    normalized.retainWhere(matchesFilter);
    final visibleRecords = await _filterRecordsForVisibleAnimals(normalized);
    visibleRecords.sort((a, b) {
      final aDate =
          DateTime.tryParse(
            (a['doseDate'] ?? a['date'] ?? a['createdAt'] ?? '').toString(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          DateTime.tryParse(
            (b['doseDate'] ?? b['date'] ?? b['createdAt'] ?? '').toString(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return visibleRecords;
  }

  // ─────────────────────────────────────────────────────────────
  // HEALTH SERVICE — DEWORMING RECORDS
  // ─────────────────────────────────────────────────────────────

  /// GET /api/health/deworming
  Future<List<dynamic>> getDewormingRecords({
    String? animalId,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (animalId != null) params['animalId'] = animalId;
    if (from != null) params['from'] = from.toIso8601String().split('T')[0];
    if (to != null) params['to'] = to.toIso8601String().split('T')[0];

    final data = await _get('/api/health/deworming', params);
    final records = _extractList(
      data,
      primaryKeys: const ['data', 'records', 'items', 'list'],
    );
    return await _filterRecordsForVisibleAnimals(records);
  }

  /// GET /api/health/reports/deworming
  Future<List<dynamic>> getDewormingReport({
    String? animalId,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (animalId != null) params['animalId'] = animalId;
    if (from != null) params['from'] = from.toIso8601String().split('T')[0];
    if (to != null) params['to'] = to.toIso8601String().split('T')[0];

    final data = await _get('/api/health/reports/deworming', params);
    final records = _extractList(
      data,
      primaryKeys: const ['data', 'records', 'items', 'list'],
    );
    return await _filterRecordsForVisibleAnimals(records);
  }

  /// GET /api/health/reports/deworming/dropdown
  Future<List<dynamic>> getDewormingReportDropdown({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    final data = await _get('/api/health/reports/deworming/dropdown', params);
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// POST /api/health/deworming
  Future<Map<String, dynamic>> addDewormingRecord({
    required String animalId,
    required DateTime doseDate,
    required String doseType, // 'INJECTION' | 'TABLET'
    String? companyName,
    String? quantity,
    String? vetId,
    DateTime? nextDoseDate,
  }) async {
    return await _post('/api/health/deworming', {
      'animalId': animalId,
      'doseDate': doseDate.toIso8601String(),
      'doseType': doseType,
      if (companyName != null) 'companyName': companyName,
      if (quantity != null) 'quantity': quantity,
      if (vetId != null) 'vetId': vetId,
      if (nextDoseDate != null) 'nextDoseDate': nextDoseDate.toIso8601String(),
    });
  }

  /// POST /api/health/deworming/bulk
  Future<Map<String, dynamic>> addBulkDewormingRecord({
    required List<String> animalIds,
    required DateTime doseDate,
    required String doseType,
    String? companyName,
    String? quantity,
    String? vetId,
    DateTime? nextDoseDate,
  }) async {
    return await _post('/api/health/deworming/bulk', {
      'animalIds': animalIds,
      'doseDate': doseDate.toIso8601String(),
      'doseType': doseType,
      if (companyName != null) 'companyName': companyName,
      if (quantity != null) 'quantity': quantity,
      if (vetId != null) 'vetId': vetId,
      if (nextDoseDate != null) 'nextDoseDate': nextDoseDate.toIso8601String(),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // HEALTH SERVICE — LAB TESTING
  // ─────────────────────────────────────────────────────────────

  /// GET /api/health/lab/master
  Future<List<dynamic>> getLabTestTypes() async {
    final data = await _get('/api/health/lab/master', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// POST /api/health/lab/master
  Future<Map<String, dynamic>> addLabTestType({required String name}) async {
    return await _post('/api/health/lab/master', {'name': name});
  }

  /// GET /api/health/lab?animalId=...
  Future<List<dynamic>> getLabRecords({String? animalId}) async {
    final params = <String, dynamic>{};
    if (animalId != null) params['animalId'] = animalId;
    final data = await _get('/api/health/lab', params);
    final records = _extractList(
      data,
      primaryKeys: const ['data', 'records', 'items', 'list'],
    );
    return await _filterRecordsForVisibleAnimals(records);
  }

  /// POST /api/health/lab
  Future<Map<String, dynamic>> addLabRecord({
    required String animalId,
    required String labtestId,
    required DateTime sampleDate,
    DateTime? resultDate,
    String? result, // 'POSITIVE' | 'NEGATIVE'
    String? attachmentUrl,
    String? remark,
  }) async {
    return await _post('/api/health/lab', {
      'animalId': animalId,
      'labtestId': labtestId,
      'sampleDate': sampleDate.toIso8601String(),
      if (resultDate != null) 'resultDate': resultDate.toIso8601String(),
      if (result != null) 'result': result,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (remark != null) 'remark': remark,
    });
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUCTION SERVICE — MILK YIELDS
  // ─────────────────────────────────────────────────────────────

  /// POST /api/production/yields — Log single daily milk yield
  Future<Map<String, dynamic>> logMilkYield({
    required String animalId,
    required String date, // 'YYYY-MM-DD'
    required double morning,
    required double evening,
    double? total,
  }) async {
    return await _post('/api/production/yields', {
      'animalId': animalId,
      'date': date,
      'morning': morning,
      'evening': evening,
      'total': total ?? (morning + evening),
    });
  }

  /// POST /api/production/yields/bulk — Log yields for multiple animals
  Future<Map<String, dynamic>> logBulkMilkYields({
    required String date,
    required String session, // Added: Required 'MORNING' or 'EVENING'
    required List<Map<String, dynamic>> entries, // Renamed from records
  }) async {
    return await _post('/api/production/yields/bulk', {
      'date': date,
      'session': session, // Required by backend
      'entries': entries, // Required by backend
    });
  }

  /// GET /api/production/yields?animalId=...&month=...&year=...
  Future<List<dynamic>> getMilkHistoryForAnimal({
    required String animalId,
    int? month,
    int? year,
  }) async {
    final params = <String, dynamic>{'animalId': animalId};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();

    final data = await _get('/api/production/yields', params);
    return data is List ? data : (data['data'] as List? ?? []);
  }

  /// GET /api/production/yields
  Future<List<dynamic>> getMilkYields() async {
    final data = await _get('/api/production/yields', {});
    return data is List ? data : (data['data'] as List? ?? []);
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUCTION SERVICE — INVENTORY
  /// GET /api/production/inventory — Fetch all feed stock levels
  Future<dynamic> getFeedInventory() async {
    return await _get('/api/production/inventory', {});
  }

  /// POST /api/production/inventory/update — Add/Update feed stock
  Future<Map<String, dynamic>> updateFeedInventory({
    required String feedName,
    required double quantity,
    String unit = "KG",
  }) async {
    return await _post('/api/production/inventory/update', {
      'feedName': feedName,
      'quantity': quantity,
      'unit': unit,
      'lastUpdated': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  // ─────────────────────────────────────────────────────────────

  /// GET /api/production/reports/daily?date=YYYY-MM-DD
  Future<Map<String, dynamic>> getDailyProductionReport({
    required String date,
  }) async {
    return await _get('/api/production/reports/daily', {'date': date});
  }

  /// GET /api/production/reports/monthly?month=M&year=Y
  Future<Map<String, dynamic>> getMonthlyProductionReport({
    required int month,
    required int year,
  }) async {
    return await _get('/api/production/reports/monthly', {
      'month': month.toString(),
      'year': year.toString(),
    });
  }

  /// GET /api/production/export/monthly?month=M&year=Y
  Future<Map<String, dynamic>> getMonthlyProductionExport({
    required int month,
    required int year,
  }) async {
    return await _get('/api/production/export/monthly', {
      'month': month.toString(),
      'year': year.toString(),
    });
  }

  Future<Map<String, dynamic>> getParityReport({
    required String animalId,
  }) async {
    return await _get('/api/production/reports/parity', {'animalId': animalId});
  }

  /// GET /api/production/reports/cow/{animalId}?month=...&year=...
  Future<Map<String, dynamic>> getCowMonthlyReport({
    required String animalId,
    required int month,
    required int year,
  }) async {
    return await _get('/api/production/reports/cow/$animalId', {
      'month': month.toString(),
      'year': year.toString(),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUCTION SERVICE — MILK DISTRIBUTION
  // ─────────────────────────────────────────────────────────────

  /// GET /api/production/categories
  Future<List<dynamic>> getMilkCategories() async {
    final data = await _get('/api/production/categories', {});
    final items = _extractList(
      data,
      primaryKeys: const ['categories', 'data', 'items', 'list'],
    );
    return items.map(_normalizeMilkCategory).toList();
  }

  /// POST /api/production/categories
  Future<Map<String, dynamic>> addMilkCategory({required String name}) async {
    return await _post('/api/production/categories', {'name': name});
  }

  /// PATCH /api/production/categories/{id}
  Future<Map<String, dynamic>> updateMilkCategory({
    required String id,
    required String name,
  }) async {
    return await _patch('/api/production/categories/$id', {'name': name});
  }

  /// DELETE /api/production/categories/{id}
  Future<Map<String, dynamic>> deleteMilkCategory({required String id}) async {
    return await _delete('/api/production/categories/$id', {});
  }

  /// POST /api/production/distribution
  Future<Map<String, dynamic>> allocateMilk({
    required String categoryId,
    required String date,
    required String session,
    required double quantity,
    String? remarks,
  }) async {
    return await _post('/api/production/distribution', {
      'categoryId': categoryId,
      'date': date,
      'session': session,
      'quantity': quantity,
      if (remarks != null) 'remarks': remarks,
    });
  }

  /// GET /api/production/distribution?date=...
  Future<List<dynamic>> getMilkDistributions({String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) params['date'] = date;
    final data = await _get('/api/production/distribution', params);
    final items = _extractList(
      data,
      primaryKeys: const ['distributions', 'data', 'items', 'list'],
    );
    return items.map(_normalizeDistributionItem).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // ANIMAL SERVICE — SUMMARY (replaces client-side counting)
  // ─────────────────────────────────────────────────────────────

  /// GET /api/animal/reports/summary
  Future<Map<String, dynamic>> getAnimalSummary() async {
    return await _get('/api/animal/reports/summary', {});
  }

  /// GET /api/animal/media/presigned-url
  Future<Map<String, dynamic>> getPresignedUrl({
    required String fileName,
    required String contentType,
    required String type, // 'PHOTO' | 'DISPOSAL' | 'DOC'
  }) async {
    final response = await _get('/api/animal/media/presigned-url', {
      'fileName': fileName,
      'contentType': contentType,
      'type': type,
    });
    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    }
    return {};
  }

  // Removed duplicate recordMedical, recordVaccination, recordDeworming methods.
  // Using addMedicalRecord, addVaccinationRecord, and addDewormingRecord instead.

  // ─────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────

  Future<dynamic> _get(String path, Map<String, dynamic> params) async {
    try {
      final response = await apiClient.get(
        path,
        queryParameters: params.isEmpty ? null : params,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e, path);
    } catch (e) {
      if (e is ServerException ||
          e is TimeoutException ||
          e is NetworkException ||
          e is AuthenticationException ||
          e is PermissionException) {
        rethrow;
      }
      throw ServerException('Failed to fetch $path', 500);
    }
  }

  Future<Map<String, dynamic>> _post(String path, dynamic body) async {
    try {
      final response = await apiClient.post(path, data: body);
      _clearVisibleAnimalRegistryCache();
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } on DioException catch (e) {
      _handleDioError(e, path);
    } catch (e) {
      if (e is ServerException ||
          e is TimeoutException ||
          e is NetworkException ||
          e is AuthenticationException ||
          e is PermissionException) {
        rethrow;
      }
      throw ServerException('Failed to post to $path', 500);
    }
  }

  Future<Map<String, dynamic>> _patch(String path, dynamic body) async {
    try {
      final response = await apiClient.patch(path, data: body);
      _clearVisibleAnimalRegistryCache();
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } on DioException catch (e) {
      _handleDioError(e, path);
    } catch (e) {
      if (e is ServerException ||
          e is TimeoutException ||
          e is NetworkException ||
          e is AuthenticationException ||
          e is PermissionException) {
        rethrow;
      }
      throw ServerException('Failed to patch $path', 500);
    }
  }

  Future<Map<String, dynamic>> _delete(
    String path,
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await apiClient.delete(
        path,
        queryParameters: params.isEmpty ? null : params,
      );
      _clearVisibleAnimalRegistryCache();
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } on DioException catch (e) {
      _handleDioError(e, path);
    } catch (e) {
      if (e is ServerException ||
          e is TimeoutException ||
          e is NetworkException ||
          e is AuthenticationException ||
          e is PermissionException) {
        rethrow;
      }
      throw ServerException('Failed to delete $path', 500);
    }
  }

  List<Map<String, dynamic>> _extractList(
    dynamic data, {
    List<String> primaryKeys = const ['data'],
  }) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      for (final key in primaryKeys) {
        final value = data[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _normalizeAnimalSummaryItem(Map<String, dynamic> item) {
    final animal = Map<String, dynamic>.from(item);
    animal['id'] = animal['id']?.toString() ?? animal['_id']?.toString() ?? '';
    animal['name'] =
        animal['name']?.toString() ??
        animal['animalName']?.toString() ??
        'Unknown';
    animal['tagNumber'] =
        animal['tagNumber']?.toString() ??
        animal['tagno']?.toString() ??
        animal['tagNo']?.toString() ??
        '';
    animal['animalNumber'] =
        animal['animalNumber']?.toString() ??
        animal['serialNumber']?.toString() ??
        animal['animalNo']?.toString() ??
        animal['number']?.toString() ??
        '';
    animal['imageUrl'] =
        animal['imageUrl'] ??
        animal['viewUrl'] ??
        animal['photoUrl'] ??
        animal['photo'];
    return animal;
  }

  Map<String, dynamic> _normalizeMilkCategory(Map<String, dynamic> item) {
    final category = Map<String, dynamic>.from(item);
    category['id'] =
        category['id']?.toString() ?? category['_id']?.toString() ?? '';
    category['name'] =
        category['name']?.toString() ??
        category['title']?.toString() ??
        category['categoryName']?.toString() ??
        '';
    return category;
  }

  Map<String, dynamic> _normalizeDistributionItem(Map<String, dynamic> item) {
    final distribution = Map<String, dynamic>.from(item);
    final category = distribution['categoryId'];
    distribution['id'] =
        distribution['id']?.toString() ?? distribution['_id']?.toString() ?? '';
    distribution['categoryName'] =
        distribution['categoryName']?.toString() ??
        distribution['name']?.toString() ??
        distribution['title']?.toString() ??
        (category is Map
            ? category['name']?.toString() ??
                  category['title']?.toString() ??
                  category['categoryName']?.toString()
            : null) ??
        '-';
    distribution['amount'] =
        double.tryParse(
          (distribution['amount'] ??
                  distribution['quantity'] ??
                  distribution['qty'] ??
                  0)
              .toString(),
        ) ??
        0.0;
    distribution['session'] =
        distribution['session']?.toString() ??
        distribution['shift']?.toString() ??
        '';
    distribution['remarks'] =
        distribution['remarks']?.toString() ??
        distribution['remark']?.toString();
    return distribution;
  }

  Map<String, dynamic> _normalizeVaccinationRecord(
    Map<String, dynamic> item, {
    Map<String, dynamic>? animal,
  }) {
    final record = Map<String, dynamic>.from(item);
    final animalRef = animal != null
        ? _normalizeAnimalSummaryItem(animal)
        : (record['animal'] is Map
            ? _normalizeAnimalSummaryItem(
                Map<String, dynamic>.from(record['animal'] as Map),
              )
            : (record['animalId'] is Map
                ? _normalizeAnimalSummaryItem(
                    Map<String, dynamic>.from(record['animalId'] as Map),
                  )
                : null));

    final vaccineRef = record['vaccine'] is Map
        ? Map<String, dynamic>.from(record['vaccine'] as Map)
        : (record['vaccineId'] is Map
            ? Map<String, dynamic>.from(record['vaccineId'] as Map)
            : null);

    record['id'] = record['id']?.toString() ?? record['_id']?.toString() ?? '';
    record['doseDate'] =
        record['doseDate']?.toString() ??
        record['date']?.toString() ??
        record['createdAt']?.toString();
    record['remark'] =
        record['remark']?.toString() ?? record['remarks']?.toString();

    if (animalRef != null) {
      record['animal'] = animalRef;
    }
    if (vaccineRef != null) {
      record['vaccine'] = vaccineRef;
      record['vaccineName'] =
          record['vaccineName']?.toString() ??
          vaccineRef['name']?.toString() ??
          vaccineRef['title']?.toString();
    }

    return record;
  }

  Future<List<Map<String, dynamic>>> _filterRecordsForVisibleAnimals(
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return records;

    final visibleAnimals = await _getVisibleAnimalRegistry();
    if (visibleAnimals.byId.isEmpty &&
        visibleAnimals.byTag.isEmpty &&
        visibleAnimals.bySerial.isEmpty &&
        visibleAnimals.byName.isEmpty) {
      return records;
    }

    final filtered = <Map<String, dynamic>>[];
    for (final record in records) {
      final match = _resolveVisibleAnimalForRecord(record, visibleAnimals);
      if (match == null) continue;

      final normalizedRecord = Map<String, dynamic>.from(record);
      normalizedRecord['animal'] = match;
      filtered.add(normalizedRecord);
    }
    return filtered;
  }

  Future<_VisibleAnimalRegistry> _getVisibleAnimalRegistry() async {
    final now = DateTime.now();
    if (_visibleAnimalRegistryCache != null &&
        _visibleAnimalRegistryCachedAt != null &&
        now.difference(_visibleAnimalRegistryCachedAt!) <
            _visibleAnimalRegistryTtl) {
      return _visibleAnimalRegistryCache!;
    }

    final cows = await getCows(limit: 500);
    final bulls = await getBulls(limit: 500);
    final allAnimals = [
      ...cows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      ...bulls.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
    ];

    final byId = <String, Map<String, dynamic>>{};
    final byTag = <String, Map<String, dynamic>>{};
    final bySerial = <String, Map<String, dynamic>>{};
    final byName = <String, Map<String, dynamic>>{};

    for (final animal in allAnimals) {
      if (!_isVisibleAnimal(animal)) continue;
      final normalized = _normalizeAnimalSummaryItem(animal);

      final id = (normalized['id'] ?? '').toString().trim();
      final tag = (normalized['tagNumber'] ?? '').toString().trim().toLowerCase();
      final serial = (normalized['animalNumber'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final name = (normalized['name'] ?? '').toString().trim().toLowerCase();

      if (id.isNotEmpty) byId[id] = normalized;
      if (tag.isNotEmpty) byTag[tag] = normalized;
      if (serial.isNotEmpty) bySerial[serial] = normalized;
      if (name.isNotEmpty) byName[name] = normalized;
    }

    final registry = _VisibleAnimalRegistry(
      byId: byId,
      byTag: byTag,
      bySerial: bySerial,
      byName: byName,
    );
    _visibleAnimalRegistryCache = registry;
    _visibleAnimalRegistryCachedAt = now;
    return registry;
  }

  void _clearVisibleAnimalRegistryCache() {
    _visibleAnimalRegistryCache = null;
    _visibleAnimalRegistryCachedAt = null;
  }

  bool _isVisibleAnimal(Map<String, dynamic> animal) {
    final normalizedStatus = (animal['status'] ?? animal['animalStatus'] ?? '')
        .toString()
        .trim()
        .toUpperCase();
    final isRetired = animal['isRetired'] == true;
    return normalizedStatus != 'SOLD' &&
        normalizedStatus != 'DEAD' &&
        normalizedStatus != 'DONATED' &&
        !isRetired;
  }

  Map<String, dynamic>? _resolveVisibleAnimalForRecord(
    Map<String, dynamic> record,
    _VisibleAnimalRegistry registry,
  ) {
    final animalRef = record['animal'];
    final animalIdRef = record['animalId'];

    Map<String, dynamic>? nestedAnimal;
    if (animalRef is Map) {
      nestedAnimal = Map<String, dynamic>.from(animalRef);
    } else if (animalIdRef is Map) {
      nestedAnimal = Map<String, dynamic>.from(animalIdRef);
    }

    final candidateIds = <String>{
      if (record['animalId'] is! Map)
        (record['animalId'] ?? '').toString().trim(),
      if (nestedAnimal != null)
        (nestedAnimal['id'] ?? nestedAnimal['_id'] ?? '').toString().trim(),
    }..removeWhere((value) => value.isEmpty);

    for (final id in candidateIds) {
      final match = registry.byId[id];
      if (match != null) return match;
    }

    final candidateTags = <String>{
      (record['animalTagNumber'] ?? record['tagNumber'] ?? record['tagno'] ?? '')
          .toString()
          .trim()
          .toLowerCase(),
      if (nestedAnimal != null)
        (nestedAnimal['tagNumber'] ??
                nestedAnimal['tagno'] ??
                nestedAnimal['tagNo'] ??
                '')
            .toString()
            .trim()
            .toLowerCase(),
    }..removeWhere((value) => value.isEmpty);

    for (final tag in candidateTags) {
      final match = registry.byTag[tag];
      if (match != null) return match;
    }

    final candidateSerials = <String>{
      (record['animalNumber'] ??
              record['animalSerialNumber'] ??
              record['serialNumber'] ??
              record['animalNo'] ??
              '')
          .toString()
          .trim()
          .toLowerCase(),
      if (nestedAnimal != null)
        (nestedAnimal['animalNumber'] ??
                nestedAnimal['serialNumber'] ??
                nestedAnimal['animalNo'] ??
                nestedAnimal['number'] ??
                '')
            .toString()
            .trim()
            .toLowerCase(),
    }..removeWhere((value) => value.isEmpty);

    for (final serial in candidateSerials) {
      final match = registry.bySerial[serial];
      if (match != null) return match;
    }

    final candidateNames = <String>{
      (record['animalName'] ?? record['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase(),
      if (nestedAnimal != null)
        (nestedAnimal['name'] ?? '').toString().trim().toLowerCase(),
    }..removeWhere((value) => value.isEmpty);

    for (final name in candidateNames) {
      final match = registry.byName[name];
      if (match != null) return match;
    }

    return null;
  }

  Never _handleDioError(DioException e, String path) {
    final msg = (e.response?.data is Map)
        ? (e.response!.data['message'] ?? 'Request failed')
        : 'Request failed';
    throw ServerException(msg as String, e.response?.statusCode ?? 500);
  }
}

class _VisibleAnimalRegistry {
  final Map<String, Map<String, dynamic>> byId;
  final Map<String, Map<String, dynamic>> byTag;
  final Map<String, Map<String, dynamic>> bySerial;
  final Map<String, Map<String, dynamic>> byName;

  const _VisibleAnimalRegistry({
    required this.byId,
    required this.byTag,
    required this.bySerial,
    required this.byName,
  });
}
