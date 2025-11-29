import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/food';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:5000/api/food';
    } else {
      return 'http://localhost:5000/api/food';
    }
  }

  static Future<Map<String, dynamic>> analyzeFood(
    String foodNameApi,
    String mealType,
    String foodNameDisplay,
  ) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    final headers = {'Content-Type': 'application/json'};

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
    final uri = Uri.parse('$_baseUrl/history');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

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
