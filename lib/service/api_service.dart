import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tubes_pemod/model/user_model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _onboardingKey = 'has_seen_onboarding';

  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:5000/api/food';
    } else {
      return 'http://localhost:5000/api/food';
    }
  }

  static Future<bool> hasSeenOnboarding() async {
    String? value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  static Future<void> completeOnboarding() async {
    await _storage.write(key: _onboardingKey, value: 'true');
  }

  // api/auth/
  static Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  static Future<void> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'email': email, 'password': password});

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: _tokenKey, value: data['token']);
      } else {
        throw Exception(data['error'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$_baseUrl/auth/register');

    final headers = {'Content-Type': 'application/json'};

    final body = json.encode({
      'nama_lengkap': name,
      'email': email,
      'password': password,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Registrasi gagal.');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  // api/user/
  static Future<UserProfile> getUserProfile() async {
    final uri = Uri.parse('$_baseUrl/user/profile');
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat profil');
    }
  }

  static Future<void> updateUserProfile(
    String name,
    int weight,
    int height,
    int calories,
    int protein,
    int fat,
    int carbs,
  ) async {
    final uri = Uri.parse('$_baseUrl/user/profile/edit');
    final headers = await _getAuthHeaders();

    final body = json.encode({
      'nama_lengkap': name,
      'berat_badan_kg': weight,
      'tinggi_badan_cm': height,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    });

    try {
      final response = await http.put(uri, headers: headers, body: body);
      debugPrint(
        "Update Profile Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal update profil: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error Update Profile: $e");
      rethrow;
    }
  }

  // api/food/
  static Future<Map<String, dynamic>> analyzeFood(
    String foodNameApi,
    String mealType,
    String foodNameDisplay,
  ) async {
    final uri = Uri.parse('$_baseUrl/food/analyze');
    final headers = await _getAuthHeaders();

    final body = json.encode({
      'foodName': foodNameApi,
      'foodNameDisplay': foodNameDisplay,
      'mealType': mealType,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Gagal menganalisis makanan.');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  static Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse('$_baseUrl/food/history');
    final headers = await _getAuthHeaders();

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Gagal mengambil riwayat.');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}
