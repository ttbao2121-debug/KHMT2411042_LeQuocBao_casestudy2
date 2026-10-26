import '../utils/constants.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = AppConstants.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint) async {
    // Stub implementation for API GET requests
    return {'status': 'success', 'data': []};
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    // Stub implementation for API POST requests
    return {'status': 'success', 'data': body};
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    // Stub implementation for API PUT requests
    return {'status': 'success', 'data': body};
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    // Stub implementation for API DELETE requests
    return {'status': 'success'};
  }
}
