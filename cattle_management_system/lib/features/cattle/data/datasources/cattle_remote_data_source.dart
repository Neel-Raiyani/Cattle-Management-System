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

  @override
  Future<List<CattleModel>> getAllCattle() async {
    try {
      final responses = await Future.wait([
        apiClient.get('/api/animal/cows'),
        apiClient.get('/api/animal/bulls'),
      ]);
      final responseCows = responses[0];
      final responseBulls = responses[1];

      // API returns { cows: [...] } and { bulls: [...] }
      final List<dynamic> cowsData =
          responseCows.data['cows'] ?? responseCows.data['data'] ?? [];
      final List<dynamic> bullsData =
          responseBulls.data['bulls'] ?? responseBulls.data['data'] ?? [];

      final cows = cowsData.map((e) {
        final map = Map<String, dynamic>.from(e);
        if (map['gender'] == null) map['gender'] = 'FEMALE';
        return CattleModel.fromJson(map);
      }).toList();

      final bulls = bullsData.map((e) {
        final map = Map<String, dynamic>.from(e);
        if (map['gender'] == null) map['gender'] = 'MALE';
        return CattleModel.fromJson(map);
      }).toList();

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
      // API returns { success: true, cows: [...], pagination: {...} }
      final List<dynamic> data =
          response.data['cows'] ?? response.data['data'] ?? [];
      return data.map((e) => CattleModel.fromJson(e)).toList();
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
      }).toList();
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
