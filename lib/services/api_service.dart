import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notdle/models/user_model.dart';
import 'package:notdle/models/company.dart';

class ApiService {
  // static const String _baseUrl = 'http://localhost:8080/api';
  static const String _baseUrl = 'https://unreprovable-jacquelynn-unconceived.ngrok-free.dev/api';
  final _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
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

  // Get company by ID
  Future<Company> getCompanyById(String companyId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/companies/$companyId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final companyData = json.decode(response.body);
        return Company.fromMap({
          ...companyData,
          'id': companyId, // Ensure ID is included in the map
        });
      } else {
        throw Exception('Failed to load company data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching company data: $e');
    }
  }

  // Get current authenticated user
  Future<User> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final user = User.fromJson(userData);
        
        // Store user data in secure storage
        await _storage.write(key: 'user_data', value: json.encode(user.toJson()));
        
        return user;
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      await _storage.delete(key: 'user_data');
      return null;
    }
  }

  // Clear stored user data
  Future<void> clearUserData() async {
    await _storage.delete(key: 'user_data');
  }

  // // Get company by ID
  // Future<Map<String, dynamic>> getCompanyById(String companyId) async {
  //   try {
  //     final headers = await _getHeaders();
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/companies/$companyId'),
  //       headers: headers,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('Failed to fetch company: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching company: $e');
  //   }
  // }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Register a new company
  Future<Map<String, dynamic>> registerCompany(Map<String, dynamic> companyData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/companies'),
        headers: headers,
        body: json.encode(companyData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Clear all user data and tokens
        await _storage.deleteAll();  // Clear all stored data
        await clearUserData();      // Clear any additional user data
        
        // Navigate to login screen if we have a valid context
        if (navigatorKey.currentContext != null) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else {
            Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }
        throw Exception('Session expired. Please login again.');
      } else {
        final error = json.decode(response.body);
        debugPrint('Registration Error: $error');
        throw Exception(error['message'] ?? 'Failed to register company');
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
      rethrow;
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
