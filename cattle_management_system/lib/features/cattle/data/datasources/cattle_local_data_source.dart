import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cattle_model.dart';

abstract class CattleLocalDataSource {
  Future<List<CattleModel>> getLastCattleList();
  Future<void> cacheCattleList(List<CattleModel> cattleList);
}

class CattleLocalDataSourceImpl implements CattleLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cattleCacheKey = 'CACHED_CATTLE_LIST';

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
}
