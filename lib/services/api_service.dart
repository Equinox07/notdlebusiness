import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // static const String _baseUrl = 'http://localhost:8080/api';
  static const String _baseUrl = 'https://unreprovable-jacquelynn-unconceived.ngrok-free.dev/api';
  final _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() => _instance;
  
  ApiService._internal();

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);
    if (data != null && data['token'] != null) {
      await _storage.write(key: 'auth_token', value: data['token']);
    }
    return data;
  }

  // User Registration
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);
    if (data != null && data['token'] != null) {
      await _storage.write(key: 'auth_token', value: data['token']);
    }
    return data;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Generic CRUD operations
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams?.map((key, value) => 
        MapEntry(key, value.toString()),
      ),
    );
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );
    
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );
    
    return _handleResponse(response);
  }

  Future<void> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    
    _handleResponse(response);
  }

  // Specific API endpoints
  // Companies
  Future<dynamic> getCompanies({int page = 0, int size = 10}) async {
    return get('/companies', queryParams: {
      'page': page,
      'size': size,
    });
  }

  // Projects
  Future<dynamic> getCompanyProjects(String companyId, {
    int page = 0, 
    int size = 10,
    String? status,
    String? clientId,
  }) async {
    return get('/companies/$companyId/projects', queryParams: {
      'page': page,
      'size': size,
      if (status != null) 'status': status,
      if (clientId != null) 'clientId': clientId,
    });
  }

  // Clients
  Future<dynamic> getClients(String companyId, {int page = 0, int size = 10}) async {
    return get('/companies/$companyId/clients', queryParams: {
      'page': page,
      'size': size,
    });
  }

  // Invoices
  Future<dynamic> getInvoices(String companyId, {
    int page = 0,
    int size = 10,
    String? status,
    String? clientId,
  }) async {
    return get('/companies/$companyId/invoices', queryParams: {
      'page': page,
      'size': size,
      if (status != null) 'status': status,
      if (clientId != null) 'clientId': clientId,
    });
  }

  // Orders
  Future<dynamic> getOrders(String companyId, {
    int page = 0,
    int size = 10,
    String? status,
    String? clientId,
  }) async {
    return get('/companies/$companyId/orders', queryParams: {
      'page': page,
      'size': size,
      if (status != null) 'status': status,
      if (clientId != null) 'clientId': clientId,
    });
  }

  // Measurements
  Future<dynamic> getMeasurements(String companyId) async {
    return get('/companies/$companyId/measurements');
  }

  Future<dynamic> createMeasurement(String companyId, Map<String, dynamic> data) async {
    return post('/v1/measurements', data);
  }

  // Search
  Future<dynamic> search(String companyId, String resource, String query, {
    int page = 0,
    int size = 10,
  }) async {
    return get('/companies/$companyId/$resource/search', queryParams: {
      'query': query,
      'page': page,
      'size': size,
    });
  }
}
