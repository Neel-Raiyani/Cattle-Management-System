import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cattle_model.dart';

abstract class CattleLocalDataSource {
  Future<List<CattleModel>> getLastCattleList();
  Future<void> cacheCattleList(List<CattleModel> cattleList);
  Future<Map<String, Map<String, String>>> getBullClassificationMap();
  Future<void> saveBullClassification(CattleModel cattle);
  Future<void> removeBullClassification(String cattleId);
}

class CattleLocalDataSourceImpl implements CattleLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cattleCacheKey = 'CACHED_CATTLE_LIST';
  static const String _bullClassificationKey = 'CACHED_BULL_CLASSIFICATION';

  CattleLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CattleModel>> getLastCattleList() async {
    final jsonString = sharedPreferences.getString(_cattleCacheKey);
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((item) => CattleModel.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheCattleList(List<CattleModel> cattleList) async {
    final String jsonString = json.encode(
      cattleList.map((model) => model.toJson()).toList(),
    );
    await sharedPreferences.setString(_cattleCacheKey, jsonString);
  }

  @override
  Future<Map<String, Map<String, String>>> getBullClassificationMap() async {
    final jsonString = sharedPreferences.getString(_bullClassificationKey);
    if (jsonString == null || jsonString.isEmpty) return {};

    final decoded = json.decode(jsonString);
    if (decoded is! Map) return {};

    final result = <String, Map<String, String>>{};
    for (final entry in decoded.entries) {
      if (entry.value is! Map) continue;
      final raw = Map<String, dynamic>.from(entry.value as Map);
      result[entry.key.toString()] = {
        if ((raw['bullType']?.toString().trim().isNotEmpty ?? false))
          'bullType': raw['bullType'].toString(),
        if ((raw['bullView']?.toString().trim().isNotEmpty ?? false))
          'bullView': raw['bullView'].toString(),
      };
    }
    return result;
  }

  @override
  Future<void> saveBullClassification(CattleModel cattle) async {
    final bullType = cattle.normalizedBullType;
    final bullView = cattle.normalizedBullView;
    if (bullType == null && bullView == null) return;

    final map = await getBullClassificationMap();
    final classification = {
      if (bullType != null) 'bullType': bullType,
      if (bullView != null) 'bullView': bullView,
    };
    if (cattle.id.isNotEmpty) {
      map[cattle.id] = classification;
    }
    final normalizedTag = cattle.tagNumber.trim().toUpperCase();
    if (normalizedTag.isNotEmpty) {
      map['tag:$normalizedTag'] = classification;
    }
    await sharedPreferences.setString(_bullClassificationKey, json.encode(map));
  }

  @override
  Future<void> removeBullClassification(String cattleId) async {
    final map = await getBullClassificationMap();
    map.remove(cattleId);
    await sharedPreferences.setString(_bullClassificationKey, json.encode(map));
  }
}
