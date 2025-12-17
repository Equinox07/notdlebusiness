import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notdle/models/user_model.dart';
import 'package:notdle/models/company.dart';

class ApiService {
  // static const String _baseUrl = 'http://localhost:8080/api';
  // static const String _baseUrl = 'https://api.notdle.com/api';
  static const String _baseUrl =
      'https://unreprovable-jacquelynn-unconceived.ngrok-free.dev/api';
  final _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
        await _storage.write(
          key: 'user_data',
          value: json.encode(user.toJson()),
        );

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

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/me'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _storage.deleteAll();
      } else {
        throw Exception('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
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
  Future<Map<String, dynamic>> registerCompany(
    Map<String, dynamic> companyData,
  ) async {
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
        await _storage.deleteAll(); // Clear all stored data
        await clearUserData(); // Clear any additional user data

        // Navigate to login screen if we have a valid context
        if (navigatorKey.currentContext != null) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else {
            Navigator.of(
              navigatorKey.currentContext!,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
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
      body: json.encode({'email': email, 'password': password}),
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

  // Update user details
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: await _getHeaders(),
      body: json.encode(userData),
    );
    
    final responseData = _handleResponse(response);
    return User.fromJson(responseData);
  }

  // Change user password
  Future<void> changePassword(String userId, String newPassword) async {
    await http.post(
      Uri.parse('$_baseUrl/users/$userId/change-password?newPassword=$newPassword'),
      headers: await _getHeaders(),
    );
  }

  // Deactivate user account
  Future<void> deactivateUser(String userId) async {
    await http.post(
      Uri.parse('$_baseUrl/users/$userId/deactivate'),
      headers: await _getHeaders(),
    );
  }

  // Activate user account
  Future<void> activateUser(String userId) async {
    await http.post(
      Uri.parse('$_baseUrl/users/$userId/activate'),
      headers: await _getHeaders(),
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Generic CRUD operations
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final response = await http.get(uri, headers: await _getHeaders());

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
    return get('/companies', queryParams: {'page': page, 'size': size});
  }

  // Update company details
  Future<Map<String, dynamic>> updateCompany(
    String companyId, 
    Map<String, dynamic> companyData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/companies/$companyId'),
      headers: await _getHeaders(),
      body: json.encode(companyData),
    );
    return _handleResponse(response);
  }

  // Deactivate company
  Future<void> deactivateCompany(String companyId) async {
    await http.post(
      Uri.parse('$_baseUrl/companies/$companyId/deactivate'),
      headers: await _getHeaders(),
    );
  }

  // Activate company
  Future<void> activateCompany(String companyId) async {
    await http.post(
      Uri.parse('$_baseUrl/companies/$companyId/activate'),
      headers: await _getHeaders(),
    );
  }

  // Search companies
  Future<dynamic> searchCompanies(String query, {int page = 0, int size = 10}) async {
    return get(
      '/companies/search',
      queryParams: {
        'query': query,
        'page': page,
        'size': size,
      },
    );
  }

  // Projects
  Future<dynamic> getCompanyProjects(
    String companyId, {
    int page = 0,
    int size = 10,
    String? status,
    String? clientId,
  }) async {
    return get(
      '/companies/$companyId/projects',
      queryParams: {
        'page': page,
        'size': size,
        if (status != null) 'status': status,
        if (clientId != null) 'clientId': clientId,
      },
    );
  }

  // Get project by ID
  Future<dynamic> getProject(String companyId, String projectId) async {
    return get('/companies/$companyId/projects/$projectId');
  }

  // Create a new project
  Future<dynamic> createProject(
    String companyId, 
    Map<String, dynamic> projectData,
  ) async {
    return post('/companies/$companyId/projects', projectData);
  }

  // Update project details
  Future<dynamic> updateProject(
    String companyId, 
    String projectId, 
    Map<String, dynamic> projectData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/companies/$companyId/projects/$projectId'),
      headers: await _getHeaders(),
      body: json.encode(projectData),
    );
    return _handleResponse(response);
  }

  // Delete a project
  Future<void> deleteProject(String companyId, String projectId) async {
    await http.delete(
      Uri.parse('$_baseUrl/companies/$companyId/projects/$projectId'),
      headers: await _getHeaders(),
    );
  }

  // Update project status
  Future<dynamic> updateProjectStatus(
    String companyId, 
    String projectId, 
    String status,
  ) async {
    return post(
      '/companies/$companyId/projects/$projectId/status/$status',
      {},
    );
  }

  // Search projects by title
  Future<dynamic> searchProjects(
    String companyId, 
    String query, {
    int page = 0, 
    int size = 10,
  }) async {
    return get(
      '/companies/$companyId/projects/search',
      queryParams: {
        'title': query,
        'page': page,
        'size': size,
      },
    );
  }

  // Get overdue projects
  Future<dynamic> getOverdueProjects(String companyId) async {
    return get('/companies/$companyId/projects/overdue');
  }

  // Get projects due between dates
  Future<dynamic> getProjectsDueBetween(
    String companyId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    return get(
      '/companies/$companyId/projects/due-between',
      queryParams: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  // Clients
  Future<dynamic> getClients(
    String companyId, {
    int page = 0,
    int size = 10,
  }) async {
    return get(
      '/companies/$companyId/clients',
      queryParams: {'page': page, 'size': size},
    );
  }

  // Get client by ID
  Future<dynamic> getClient(String companyId, String clientId) async {
    return get('/companies/$companyId/clients/$clientId');
  }

  // Create a new client
  Future<dynamic> createClient(
    String companyId, 
    Map<String, dynamic> clientData,
  ) async {
    return post('/companies/$companyId/clients', clientData);
  }

  // Update client details
  Future<dynamic> updateClient(
    String companyId, 
    String clientId, 
    Map<String, dynamic> clientData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/companies/$companyId/clients/$clientId'),
      headers: await _getHeaders(),
      body: json.encode(clientData),
    );
    return _handleResponse(response);
  }

  // Delete a client
  Future<void> deleteClient(String companyId, String clientId) async {
    await http.delete(
      Uri.parse('$_baseUrl/companies/$companyId/clients/$clientId'),
      headers: await _getHeaders(),
    );
  }

  // Search clients by name
  Future<dynamic> searchClients(
    String companyId, 
    String query, {
    int page = 0, 
    int size = 10,
  }) async {
    return get(
      '/companies/$companyId/clients/search',
      queryParams: {
        'name': query,
        'page': page,
        'size': size,
      },
    );
  }

  // Invoices
  Future<dynamic> getInvoices(
    String companyId, {
    int page = 0,
    int size = 10,
    String? status,
    String? clientId,
  }) async {
    return get(
      '/companies/$companyId/invoices',
      queryParams: {
        'page': page,
        'size': size,
        if (status != null) 'status': status,
        if (clientId != null) 'clientId': clientId,
      },
    );
  }

  // Get invoice by ID
  Future<dynamic> getInvoice(String companyId, String invoiceId) async {
    return get('/companies/$companyId/invoices/$invoiceId');
  }

  // Get invoice by invoice number
  Future<dynamic> getInvoiceByNumber(
    String companyId, 
    String invoiceNumber,
  ) async {
    return get('/companies/$companyId/invoices/by-number/$invoiceNumber');
  }

  // Create a new invoice
  Future<dynamic> createInvoice(
    String companyId, 
    Map<String, dynamic> invoiceData,
  ) async {
    return post('/companies/$companyId/invoices', invoiceData);
  }

  // Update invoice details
  Future<dynamic> updateInvoice(
    String companyId, 
    String invoiceId, 
    Map<String, dynamic> invoiceData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/companies/$companyId/invoices/$invoiceId'),
      headers: await _getHeaders(),
      body: json.encode(invoiceData),
    );
    return _handleResponse(response);
  }

  // Delete an invoice
  Future<void> deleteInvoice(String companyId, String invoiceId) async {
    await http.delete(
      Uri.parse('$_baseUrl/companies/$companyId/invoices/$invoiceId'),
      headers: await _getHeaders(),
    );
  }

  // Update invoice status
  Future<dynamic> updateInvoiceStatus(
    String companyId, 
    String invoiceId, 
    String status,
  ) async {
    return post(
      '/companies/$companyId/invoices/$invoiceId/status/$status',
      {},
    );
  }

  // Get upcoming due invoices
  Future<dynamic> getUpcomingDueInvoices(
    String companyId, 
    DateTime endDate,
  ) async {
    return get(
      '/companies/$companyId/invoices/upcoming-due',
      queryParams: {
        'endDate': endDate.toIso8601String().split('T')[0], // Date only
      },
    );
  }

  // Get overdue invoices
  Future<dynamic> getOverdueInvoices(String companyId) async {
    return get('/companies/$companyId/invoices/overdue');
  }

  // Get total overdue amount
  Future<num> getTotalOverdueAmount(String companyId) async {
    final response = await get(
      '/companies/$companyId/invoices/overdue-amount',
    );
    return response is num ? response : 0;
  }

  // Get invoices by date range
  Future<dynamic> getInvoicesByDateRange(
    String companyId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    return get(
      '/companies/$companyId/invoices/by-date-range',
      queryParams: {
        'startDate': startDate.toIso8601String().split('T')[0], // Date only
        'endDate': endDate.toIso8601String().split('T')[0], // Date only
      },
    );
  }

  // Calculate invoice revenue for a date range
  Future<num> calculateInvoiceRevenue(
    String companyId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    final response = await get(
      '/companies/$companyId/invoices/revenue',
      queryParams: {
        'startDate': startDate.toIso8601String().split('T')[0], // Date only
        'endDate': endDate.toIso8601String().split('T')[0], // Date only
      },
    );
    return response is num ? response : 0;
  }

  // Orders
  Future<dynamic> getOrders(
    String companyId, {
    int page = 0,
    int size = 10,
    String? status,
    String? clientId,
  }) async {
    return get(
      '/companies/$companyId/orders',
      queryParams: {
        'page': page,
        'size': size,
        if (status != null) 'status': status,
        if (clientId != null) 'clientId': clientId,
      },
    );
  }

  // Get order by ID
  Future<dynamic> getOrder(String companyId, String orderId) async {
    return get('/companies/$companyId/orders/$orderId');
  }

  // Create a new order
  Future<dynamic> createOrder(
    String companyId, 
    Map<String, dynamic> orderData,
  ) async {
    return post('/companies/$companyId/orders', orderData);
  }

  // Update order details
  Future<dynamic> updateOrder(
    String companyId, 
    String orderId, 
    Map<String, dynamic> orderData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/companies/$companyId/orders/$orderId'),
      headers: await _getHeaders(),
      body: json.encode(orderData),
    );
    return _handleResponse(response);
  }

  // Delete an order
  Future<void> deleteOrder(String companyId, String orderId) async {
    await http.delete(
      Uri.parse('$_baseUrl/companies/$companyId/orders/$orderId'),
      headers: await _getHeaders(),
    );
  }

  // Update order status
  Future<dynamic> updateOrderStatus(
    String companyId, 
    String orderId, 
    String status,
  ) async {
    return post(
      '/companies/$companyId/orders/$orderId/status/$status',
      {},
    );
  }

  // Add item to order
  Future<dynamic> addOrderItem(
    String companyId, 
    String orderId, 
    Map<String, dynamic> itemData,
  ) async {
    return post(
      '/companies/$companyId/orders/$orderId/items',
      itemData,
    );
  }

  // Remove item from order
  Future<dynamic> removeOrderItem(
    String companyId, 
    String orderId, 
    String itemId,
  ) async {
    return delete(
      '/companies/$companyId/orders/$orderId/items/$itemId',
    );
  }

  // Search orders by order number
  Future<dynamic> searchOrders(
    String companyId, 
    String query, {
    int page = 0, 
    int size = 10,
  }) async {
    return get(
      '/companies/$companyId/orders/search',
      queryParams: {
        'orderNumber': query,
        'page': page,
        'size': size,
      },
    );
  }

  // Calculate revenue for a date range
  Future<num> calculateOrderRevenue(
    String companyId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    final response = await get(
      '/companies/$companyId/orders/revenue',
      queryParams: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
    return response is num ? response : 0;
  }

  // Get orders by date range
  Future<dynamic> getOrdersByDateRange(
    String companyId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    return get(
      '/companies/$companyId/orders/by-date-range',
      queryParams: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  // Payments
  Future<dynamic> getPayments({
    int page = 0,
    int size = 10,
  }) async {
    return get(
      '/payments',
      queryParams: {'page': page, 'size': size},
    );
  }

  // Get payment by ID
  Future<dynamic> getPayment(String paymentId) async {
    return get('/payments/$paymentId');
  }

  // Create a new payment
  Future<dynamic> createPayment(Map<String, dynamic> paymentData) async {
    return post('/payments', paymentData);
  }

  // Update payment details
  Future<dynamic> updatePayment(
    String paymentId, 
    Map<String, dynamic> paymentData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/payments/$paymentId'),
      headers: await _getHeaders(),
      body: json.encode(paymentData),
    );
    return _handleResponse(response);
  }

  // Delete a payment
  Future<void> deletePayment(String paymentId) async {
    await http.delete(
      Uri.parse('$_baseUrl/payments/$paymentId'),
      headers: await _getHeaders(),
    );
  }

  // Get payments for a specific invoice
  Future<dynamic> getInvoicePayments(String invoiceId) async {
    return get('/payments', queryParams: {'invoiceId': invoiceId});
  }

  // Get payments for a specific company
  Future<dynamic> getCompanyPayments(
    String companyId, {
    int page = 0,
    int size = 10,
  }) async {
    return get(
      '/payments',
      queryParams: {
        'companyId': companyId,
        'page': page,
        'size': size,
      },
    );
  }

  // Get payments by date range
  Future<dynamic> getPaymentsByDateRange(
    DateTime startDate, 
    DateTime endDate, {
    String? companyId,
    int page = 0,
    int size = 10,
  }) async {
    final params = <String, dynamic>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'page': page,
      'size': size,
    };
    
    if (companyId != null) {
      params['companyId'] = companyId;
    }
    
    return get(
      '/payments/by-date-range',
      queryParams: params,
    );
  }

  // Measurements
  // Get all measurements for a company
  Future<dynamic> getMeasurements(String companyId) async {
    return get('/companies/$companyId/measurements');
  }

  // Get measurement by ID
  Future<dynamic> getMeasurement(String measurementId) async {
    return get('/v1/measurements/$measurementId');
  }

  // Create a new measurement
  Future<dynamic> createMeasurement(
    String companyId,
    Map<String, dynamic> data,
  ) async {
    // Ensure companyId is included in the measurement data
    final measurementData = Map<String, dynamic>.from(data);
    measurementData['companyId'] = companyId;
    
    return post('/v1/measurements', measurementData);
  }

  // Update a measurement
  Future<dynamic> updateMeasurement(
    String measurementId, 
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/v1/measurements/$measurementId'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // Delete a measurement
  Future<void> deleteMeasurement(String measurementId) async {
    await http.delete(
      Uri.parse('$_baseUrl/v1/measurements/$measurementId'),
      headers: await _getHeaders(),
    );
  }

  // Get all measurements for a specific client
  Future<dynamic> getClientMeasurements(String clientId) async {
    return get('/v1/measurements', queryParams: {'clientId': clientId});
  }

  // Delete a specific measurement for a client
  Future<void> deleteClientMeasurement(
    String measurementId, 
    String clientId,
  ) async {
    await http.delete(
      Uri.parse('$_baseUrl/v1/measurements/$measurementId/client/$clientId'),
      headers: await _getHeaders(),
    );
  }

  // Count all measurements for a company
  Future<int> countCompanyMeasurements(String companyId) async {
    final response = await get('/api/companies/$companyId/measurements/count');
    return response is int ? response : 0;
  }

  // Search
  Future<dynamic> search(
    String companyId,
    String resource,
    String query, {
    int page = 0,
    int size = 10,
  }) async {
    return get(
      '/companies/$companyId/$resource/search',
      queryParams: {'query': query, 'page': page, 'size': size},
    );
  }
}
