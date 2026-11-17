import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = AppConstants.baseUrl});

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> data = decoded is Map<String, dynamic> ? decoded : {};
        final msg = data['message'] ??
            (data['errors'] != null && (data['errors'] as List).isNotEmpty
                ? data['errors'][0]['msg']
                : 'Lỗi máy chủ (${response.statusCode})');
        throw Exception(msg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi kết nối máy chủ Backend: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> data = decoded is Map<String, dynamic> ? decoded : {};
        final msg = data['message'] ?? 'Lỗi kết nối máy chủ';
        throw Exception(msg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi kết nối máy chủ Backend: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> data = decoded is Map<String, dynamic> ? decoded : {};
        final msg = data['message'] ?? 'Lỗi cập nhật dữ liệu (${response.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi kết nối máy chủ Backend.');
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> data = decoded is Map<String, dynamic> ? decoded : {};
        final msg = data['message'] ?? 'Lỗi cập nhật dữ liệu (${response.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi kết nối máy chủ Backend.');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(url, headers: headers);
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> data = decoded is Map<String, dynamic> ? decoded : {};
        final msg = data['message'] ?? 'Lỗi xóa dữ liệu (${response.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi kết nối máy chủ Backend.');
    }
  }
}
