import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final loginUrl = 'https://cattle-management-system-1.onrender.com/api/auth/login';
  try {
    final loginRes = await dio.post(loginUrl, data: {
      "mobileNumber": "9876543210",
      "password": "password123",
    });
    
    final token = loginRes.data['token'];
    final gaushalaId = loginRes.data['gaushalas'][0]['id'];
    
    print("GaushalaId: $gaushalaId");
    
    // Now request cows
    final cowsUrl = 'https://cattle-management-system-1.onrender.com/api/animal/cows';
    final getCowsRes = await dio.get(cowsUrl, options: Options(headers: {
      'Authorization': 'Bearer $token',
      'gaushala-id': gaushalaId
    }));
    print("Cows Response Keys: ${getCowsRes.data.keys.toList()}");
    print("Cows Data: ${jsonEncode(getCowsRes.data)}");

  } on DioException catch (e) {
    print("Error ${e.response?.statusCode}: ${e.response?.data}");
  }
}
