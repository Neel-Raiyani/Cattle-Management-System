import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<bool> registerUser(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> loginUser(String mobile, String password);
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<String?> getCurrentUserMobile();
  Future<bool> isUserRegistered(String mobile);
  Future<bool> changePassword(String mobile, String newPassword);
  Future<Map<String, dynamic>?> getCurrentUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> registerUser(Map<String, dynamic> userData) async {
    final mobile = userData['mobile'];

    // Check if user exists
    if (sharedPreferences.containsKey('user_$mobile')) {
      return false; // User exists
    }

    final userJson = jsonEncode(userData);
    await sharedPreferences.setString('user_$mobile', userJson);
    return true;
  }

  @override
  Future<Map<String, dynamic>?> loginUser(
    String mobile,
    String password,
  ) async {
    final userJson = sharedPreferences.getString('user_$mobile');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      // Since default register has password=mobile, check that.
      if (userData['password'] == password) {
        // Set logged in session
        await sharedPreferences.setString('current_user', mobile);
        return userData;
      }
    }
    return null; // Invalid user or password
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.containsKey('current_user');
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove('current_user');
  }

  @override
  Future<String?> getCurrentUserMobile() async {
    return sharedPreferences.getString('current_user');
  }

  @override
  Future<bool> isUserRegistered(String mobile) async {
    return sharedPreferences.containsKey('user_$mobile');
  }

  @override
  Future<bool> changePassword(String mobile, String newPassword) async {
    final userKey = 'user_$mobile';
    final userJson = sharedPreferences.getString(userKey);
    if (userJson != null) {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      userData['password'] = newPassword;
      await sharedPreferences.setString(userKey, jsonEncode(userData));
      return true;
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final mobile = sharedPreferences.getString('current_user');
    if (mobile != null) {
      final userJson = sharedPreferences.getString('user_$mobile');
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
    }
    return null;
  }
}
