import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/cattle_model.dart';
import '../../domain/entities/cattle.dart';

abstract class CattleRemoteDataSource {
  Future<List<CattleModel>> getAllCattle();
  Future<List<CattleModel>> getCows();
  Future<List<CattleModel>> getBulls();
  Future<CattleModel> getCattleById(String id);
  Future<CattleModel> addCattle(Cattle cattle);
  Future<CattleModel> updateCattle(Cattle cattle);
  Future<void> deleteCattle(String id);
}

class CattleRemoteDataSourceImpl implements CattleRemoteDataSource {
  final ApiClient apiClient;

  CattleRemoteDataSourceImpl(this.apiClient);

  bool _isRenderableImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final normalized = value.trim().toLowerCase();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  bool _isVisibleAnimalJson(Map<String, dynamic> item) {
    final status = (item['status'] ?? item['animalStatus'] ?? '')
        .toString()
        .trim()
        .toUpperCase();
    final isRetired = item['isRetired'] == true;
    return status != 'SOLD' &&
        status != 'DEAD' &&
        status != 'DONATED' &&
        !isRetired;
  }

  Future<Map<String, Map<String, bool>>> _fetchJourneyStatusByAnimalId() async {
    try {
      final response = await apiClient.get('/api/breeding/journey/list');
      final data = response.data;
      final rawList = data is List
          ? data
          : (data is Map ? (data['data'] as List? ?? const []) : const []);
      final result = <String, Map<String, bool>>{};

      for (final raw in rawList.whereType<Map>()) {
        final item = Map<String, dynamic>.from(raw);
        final animal = item['animal'] is Map
            ? Map<String, dynamic>.from(item['animal'] as Map)
            : (item['animalId'] is Map
                ? Map<String, dynamic>.from(item['animalId'] as Map)
                : <String, dynamic>{});
        final animalId =
            (animal['id'] ??
                    animal['_id'] ??
                    (item['animalId'] is String ? item['animalId'] : item['cowId']))
                ?.toString() ??
            '';
        if (animalId.isEmpty) continue;

        final stage = item['currentStage']?.toString().toUpperCase() ?? '';
        final isDelivered =
            item['isDelivered'] == true ||
            stage == 'DELIVERED' ||
            stage == 'COMPLETED' ||
            stage == 'CLOSED';
        if (isDelivered) continue;

        final existing = result[animalId] ?? {'isPregnant': false, 'isDryOff': false};
        existing['isPregnant'] =
            existing['isPregnant'] == true ||
            item['isPregnant'] == true ||
            stage == 'PD_CONFIRMED' ||
            stage == 'DRY_OFF';
        existing['isDryOff'] =
            existing['isDryOff'] == true ||
            item['isDryOff'] == true ||
            stage == 'DRY_OFF';
        result[animalId] = existing;
      }

      return result;
    } catch (_) {
      return const {};
    }
  }

  Map<String, dynamic> _applyJourneyStatus(
    Map<String, dynamic> item,
    Map<String, Map<String, bool>> journeyStatusByAnimalId,
  ) {
    final updated = Map<String, dynamic>.from(item);
    final animalId = (updated['id'] ?? updated['_id'])?.toString() ?? '';
    final status = journeyStatusByAnimalId[animalId];
    if (status == null) return updated;

    updated['isPregnant'] = status['isPregnant'] == true;
    updated['isDryOff'] = status['isDryOff'] == true;
    if (status['isPregnant'] == true || status['isDryOff'] == true) {
      updated['isHeifer'] = false;
    }
    if (status['isDryOff'] == true) {
      updated['isLactating'] = false;
    }
    return updated;
  }

  @override
  Future<List<CattleModel>> getAllCattle() async {
    try {
      final responses = await Future.wait([
        apiClient.get('/api/animal/cows'),
        apiClient.get('/api/animal/bulls'),
      ]);
      final journeyStatusByAnimalId = await _fetchJourneyStatusByAnimalId();
      final responseCows = responses[0];
      final responseBulls = responses[1];

      // API returns { cows: [...] } and { bulls: [...] }
      final List<dynamic> cowsData =
          responseCows.data['cows'] ?? responseCows.data['data'] ?? [];
      final List<dynamic> bullsData =
          responseBulls.data['bulls'] ?? responseBulls.data['data'] ?? [];

      final cows = cowsData.map((e) {
        final map = _applyJourneyStatus(
          Map<String, dynamic>.from(e),
          journeyStatusByAnimalId,
        );
        if (map['gender'] == null) map['gender'] = 'FEMALE';
        return CattleModel.fromJson(map);
      }).where((item) => _isVisibleAnimalJson(item.toJson())).toList();

      final bulls = bullsData.map((e) {
        final map = Map<String, dynamic>.from(e);
        if (map['gender'] == null) map['gender'] = 'MALE';
        return CattleModel.fromJson(map);
      }).where((item) => _isVisibleAnimalJson(item.toJson())).toList();

      // Deduplicate by ID and favor Bull endpoint data if it appears in both lists
      final Map<String, CattleModel> uniqueCattle = {};
      for (var cow in cows) {
        uniqueCattle[cow.id] = cow;
      }
      for (var bull in bulls) {
        uniqueCattle[bull.id] = bull;
      }

      return uniqueCattle.values.toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is DioException) {
        final message =
            e.response?.data?['message'] ?? 'Failed to load cattle data';
        throw ServerException(message, e.response?.statusCode);
      }
      throw ServerException('Failed to load cattle data: $e', 500);
    }
  }

  @override
  Future<List<CattleModel>> getCows() async {
    try {
      final response = await apiClient.get('/api/animal/cows');
      final journeyStatusByAnimalId = await _fetchJourneyStatusByAnimalId();
      // API returns { success: true, cows: [...], pagination: {...} }
      final List<dynamic> data =
          response.data['cows'] ?? response.data['data'] ?? [];
      return data
          .whereType<Map>()
          .map(
            (e) => _applyJourneyStatus(
              Map<String, dynamic>.from(e),
              journeyStatusByAnimalId,
            ),
          )
          .where(_isVisibleAnimalJson)
          .map(CattleModel.fromJson)
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is DioException) {
        final message = e.response?.data?['message'] ?? 'Failed to load cows';
        throw ServerException(message, e.response?.statusCode);
      }
      throw ServerException('Failed to load cows: $e', 500);
    }
  }

  @override
  Future<List<CattleModel>> getBulls() async {
    try {
      final response = await apiClient.get('/api/animal/bulls');
      // API returns { success: true, bulls: [...], pagination: {...} }
      final List<dynamic> data =
          response.data['bulls'] ?? response.data['data'] ?? [];
      return data.map((e) {
        final map = Map<String, dynamic>.from(e);
        if (map['gender'] == null) map['gender'] = 'MALE';
        return CattleModel.fromJson(map);
      }).where((item) => _isVisibleAnimalJson(item.toJson())).toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is DioException) {
        final message = e.response?.data?['message'] ?? 'Failed to load bulls';
        throw ServerException(message, e.response?.statusCode);
      }
      throw ServerException('Failed to load bulls: $e', 500);
    }
  }

  @override
  Future<CattleModel> getCattleById(String id) async {
    try {
      final response = await apiClient.get('/api/animal/$id');
      final data = response.data['data'] ?? response.data;
      return CattleModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get cattle', 500);
    }
  }

  @override
  Future<CattleModel> addCattle(Cattle cattle) async {
    try {
      // Build payload — never send 'id' for new records (MongoDB will generate it)
      final model = (cattle is CattleModel)
          ? cattle
          : CattleModel(
              id: '', // empty so toJson skips it
              tagNumber: cattle.tagNumber,
              name: cattle.name,
              breed: cattle.breed,
              gender: cattle.gender,
              dateOfBirth: cattle.dateOfBirth,
              status: cattle.status,
              createdAt: cattle.createdAt,
              updatedAt: cattle.updatedAt,
              color: cattle.color,
              weight: cattle.weight,
              imageUrl: cattle.imageUrl,
              acquisitionType: cattle.acquisitionType,
              parity: cattle.parity,
              lastDeliveryDate: cattle.lastDeliveryDate,
              dailyMilkProduction: cattle.dailyMilkProduction,
              serialNumber: cattle.serialNumber,
              motherId: cattle.motherId,
              fatherId: cattle.fatherId,
              motherName: cattle.motherName,
              fatherName: cattle.fatherName,
              isRetired: cattle.isRetired,
              isLactating: cattle.isLactating,
              isHeifer: cattle.isHeifer,
              isPregnant: cattle.isPregnant,
              isDryOff: cattle.isDryOff,
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
              bullType: cattle.bullType,
              bullView: cattle.bullView,
              motherMilk: cattle.motherMilk,
              grandmotherMilk: cattle.grandmotherMilk,
            );

      final json = model.toJson();
      json.remove('id');
      json.remove('_id');

      final response = await apiClient.post('/api/animal/add', data: json);
      // API returns { success, message, animal: {...} }
      final responseData =
          response.data['animal'] ?? response.data['data'] ?? response.data;
      final Map<String, dynamic> combinedData = Map<String, dynamic>.from(
        responseData,
      );
      // Ensure gender belongs to the animal we added
      if (combinedData['gender'] == null) {
        combinedData['gender'] = cattle.gender;
      }
      if ((!_isRenderableImageUrl(combinedData['viewUrl']?.toString()) &&
              !_isRenderableImageUrl(combinedData['imageUrl']?.toString()) &&
              !_isRenderableImageUrl(combinedData['photoUrl']?.toString())) &&
          _isRenderableImageUrl(cattle.imageUrl)) {
        combinedData['photoUrl'] = cattle.imageUrl;
        combinedData['imageUrl'] = cattle.imageUrl;
        combinedData['viewUrl'] = cattle.imageUrl;
      }
      final createdId =
          combinedData['_id']?.toString() ?? combinedData['id']?.toString() ?? '';
      if (createdId.isNotEmpty) {
        try {
          final fetched = await getCattleById(createdId);
          if (!_isRenderableImageUrl(fetched.imageUrl) &&
              _isRenderableImageUrl(cattle.imageUrl)) {
            return CattleModel.fromJson(
              Map<String, dynamic>.from(fetched.toJson())
                ..['id'] = fetched.id
                ..['photoUrl'] = cattle.imageUrl
                ..['imageUrl'] = cattle.imageUrl
                ..['viewUrl'] = cattle.imageUrl,
            );
          }
          return fetched;
        } catch (_) {}
      }
      return CattleModel.fromJson(combinedData);
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is DioException) {
        final message = e.response?.data?['message'] ?? 'Failed to add cattle';
        throw ServerException(message, e.response?.statusCode);
      }
      throw ServerException('Failed to add cattle: $e', 500);
    }
  }

  @override
  Future<CattleModel> updateCattle(Cattle cattle) async {
    try {
      final json = (cattle is CattleModel)
          ? cattle.toJson()
          : CattleModel(
              id: cattle.id,
              tagNumber: cattle.tagNumber,
              name: cattle.name,
              breed: cattle.breed,
              gender: cattle.gender,
              dateOfBirth: cattle.dateOfBirth,
              status: cattle.status,
              createdAt: cattle.createdAt,
              updatedAt: cattle.updatedAt,
              color: cattle.color,
              weight: cattle.weight,
              imageUrl: cattle.imageUrl,
              acquisitionType: cattle.acquisitionType,
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
              isRetired: cattle.isRetired,
              isLactating: cattle.isLactating,
              isHeifer: cattle.isHeifer,
              isPregnant: cattle.isPregnant,
              isDryOff: cattle.isDryOff,
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
              bullType: cattle.bullType,
              bullView: cattle.bullView,
              motherMilk: cattle.motherMilk,
              grandmotherMilk: cattle.grandmotherMilk,
            ).toJson();

      // Many APIs don't like 'id' in the PATCH body if it's in the URL
      json.remove('id');
      json.remove('_id');

      final response = await apiClient.patch(
        '/api/animal/update/${cattle.id}',
        data: json,
      );
      // API returns { success, message, animal: {...} }
      final responseData =
          response.data['animal'] ?? response.data['data'] ?? response.data;
      final Map<String, dynamic> combinedData = Map<String, dynamic>.from(
        responseData,
      );
      // Ensure gender remains correct
      if (combinedData['gender'] == null) {
        combinedData['gender'] = cattle.gender;
      }
      if ((!_isRenderableImageUrl(combinedData['viewUrl']?.toString()) &&
              !_isRenderableImageUrl(combinedData['imageUrl']?.toString()) &&
              !_isRenderableImageUrl(combinedData['photoUrl']?.toString())) &&
          _isRenderableImageUrl(cattle.imageUrl)) {
        combinedData['photoUrl'] = cattle.imageUrl;
        combinedData['imageUrl'] = cattle.imageUrl;
        combinedData['viewUrl'] = cattle.imageUrl;
      }
      final updatedId =
          combinedData['_id']?.toString() ?? combinedData['id']?.toString() ?? cattle.id;
      if (updatedId.isNotEmpty) {
        try {
          final fetched = await getCattleById(updatedId);
          if (!_isRenderableImageUrl(fetched.imageUrl) &&
              _isRenderableImageUrl(cattle.imageUrl)) {
            return CattleModel.fromJson(
              Map<String, dynamic>.from(fetched.toJson())
                ..['id'] = fetched.id
                ..['photoUrl'] = cattle.imageUrl
                ..['imageUrl'] = cattle.imageUrl
                ..['viewUrl'] = cattle.imageUrl,
            );
          }
          return fetched;
        } catch (_) {}
      }
      return CattleModel.fromJson(combinedData);
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is DioException) {
        final message =
            e.response?.data?['message'] ?? 'Failed to update cattle';
        throw ServerException(message, e.response?.statusCode);
      }
      throw ServerException('Failed to update cattle: $e', 500);
    }
  }

  @override
  Future<void> deleteCattle(String id) async {
    try {
      await apiClient.delete('/api/animal/$id');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete cattle', 500);
    }
  }
}
