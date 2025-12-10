import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'https://unreprovable-jacquelynn-unconceived.ngrok-free.dev/api';

  ApiClient() {
    _dio.options.baseUrl = _baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.data != null && response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
      }
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<Response> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      return await _dio.post('/auth/signup', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw Exception('Failed to signup: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Companies
  Future<Response> getAllCompanies({int page = 0, int size = 10}) async {
    try {
      return await _dio.get('/companies', queryParameters: {
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to get companies: $e');
    }
  }

  Future<Response> createCompany(Map<String, dynamic> companyData) async {
    try {
      return await _dio.post('/companies', data: companyData);
    } catch (e) {
      throw Exception('Failed to create company: $e');
    }
  }

  Future<Response> getCompanyById(String id) async {
    try {
      return await _dio.get('/companies/$id');
    } catch (e) {
      throw Exception('Failed to get company: $e');
    }
  }

  Future<Response> updateCompany(String id, Map<String, dynamic> companyData) async {
    try {
      return await _dio.put('/companies/$id', data: companyData);
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  Future<Response> deleteCompany(String id) async {
    try {
      return await _dio.delete('/companies/$id');
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }

  Future<Response> activateCompany(String id) async {
    try {
      return await _dio.post('/companies/$id/activate');
    } catch (e) {
      throw Exception('Failed to activate company: $e');
    }
  }

  Future<Response> deactivateCompany(String id) async {
    try {
      return await _dio.post('/companies/$id/deactivate');
    } catch (e) {
      throw Exception('Failed to deactivate company: $e');
    }
  }

  // Projects
  Future<Response> getAllProjects(String companyId, {
    String? status,
    String? clientId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      return await _dio.get('/companies/$companyId/projects', queryParameters: {
        'status': status,
        'clientId': clientId,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }

  Future<Response> createProject(String companyId, Map<String, dynamic> projectData) async {
    try {
      return await _dio.post('/companies/$companyId/projects', data: projectData);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<Response> getProjectById(String companyId, String id) async {
    try {
      return await _dio.get('/companies/$companyId/projects/$id');
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  Future<Response> updateProject(String companyId, String id, Map<String, dynamic> projectData) async {
    try {
      return await _dio.put('/companies/$companyId/projects/$id', data: projectData);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<Response> deleteProject(String companyId, String id) async {
    try {
      return await _dio.delete('/companies/$companyId/projects/$id');
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<Response> updateProjectStatus(String companyId, String id, String status) async {
    try {
      return await _dio.post('/companies/$companyId/projects/$id/status/$status');
    } catch (e) {
      throw Exception('Failed to update project status: $e');
    }
  }

  Future<Response> searchProjects(String companyId, String title, {int page = 0, int size = 10}) async {
    try {
      return await _dio.get('/companies/$companyId/projects/search', queryParameters: {
        'title': title,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to search projects: $e');
    }
  }

  Future<Response> getOverdueProjects(String companyId) async {
    try {
      return await _dio.get('/companies/$companyId/projects/overdue');
    } catch (e) {
      throw Exception('Failed to get overdue projects: $e');
    }
  }

  Future<Response> getProjectsDueBetween(String companyId, String startDate, String endDate) async {
    try {
      return await _dio.get('/companies/$companyId/projects/due-between', queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      });
    } catch (e) {
      throw Exception('Failed to get projects due between: $e');
    }
  }

  // Clients
  Future<Response> getAllClients(String companyId, {int page = 0, int size = 10}) async {
    try {
      return await _dio.get('/companies/$companyId/clients', queryParameters: {
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to get clients: $e');
    }
  }

  Future<Response> createClient(String companyId, Map<String, dynamic> clientData) async {
    try {
      return await _dio.post('/companies/$companyId/clients', data: clientData);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  Future<Response> getClientById(String companyId, String id) async {
    try {
      return await _dio.get('/companies/$companyId/clients/$id');
    } catch (e) {
      throw Exception('Failed to get client: $e');
    }
  }

  Future<Response> updateClient(String companyId, String id, Map<String, dynamic> clientData) async {
    try {
      return await _dio.put('/companies/$companyId/clients/$id', data: clientData);
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  Future<Response> deleteClient(String companyId, String id) async {
    try {
      return await _dio.delete('/companies/$companyId/clients/$id');
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  Future<Response> searchClients(String companyId, String name, {int page = 0, int size = 10}) async {
    try {
      return await _dio.get('/companies/$companyId/clients/search', queryParameters: {
        'name': name,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to search clients: $e');
    }
  }

  // Invoices
  Future<Response> getAllInvoices(String companyId, {
    String? status,
    String? clientId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      return await _dio.get('/companies/$companyId/invoices', queryParameters: {
        'status': status,
        'clientId': clientId,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to get invoices: $e');
    }
  }

  Future<Response> createInvoice(String companyId, Map<String, dynamic> invoiceData) async {
    try {
      return await _dio.post('/companies/$companyId/invoices', data: invoiceData);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  Future<Response> getInvoiceById(String companyId, String id) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/$id');
    } catch (e) {
      throw Exception('Failed to get invoice: $e');
    }
  }

  Future<Response> updateInvoice(String companyId, String id, Map<String, dynamic> invoiceData) async {
    try {
      return await _dio.put('/companies/$companyId/invoices/$id', data: invoiceData);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  Future<Response> deleteInvoice(String companyId, String id) async {
    try {
      return await _dio.delete('/companies/$companyId/invoices/$id');
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  Future<Response> updateInvoiceStatus(String companyId, String id, String status) async {
    try {
      return await _dio.post('/companies/$companyId/invoices/$id/status/$status');
    } catch (e) {
      throw Exception('Failed to update invoice status: $e');
    }
  }

  Future<Response> addPayment(String companyId, String id, Map<String, dynamic> paymentData) async {
    try {
      return await _dio.post('/companies/$companyId/invoices/$id/payments', data: paymentData);
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  Future<Response> getUpcomingDueInvoices(String companyId, String endDate) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/upcoming-due', queryParameters: {
        'endDate': endDate,
      });
    } catch (e) {
      throw Exception('Failed to get upcoming due invoices: $e');
    }
  }

  Future<Response> calculateInvoiceRevenue(String companyId, String startDate, String endDate) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/revenue', queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      });
    } catch (e) {
      throw Exception('Failed to calculate invoice revenue: $e');
    }
  }

  Future<Response> getOverdueInvoices(String companyId) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/overdue');
    } catch (e) {
      throw Exception('Failed to get overdue invoices: $e');
    }
  }

  Future<Response> getTotalOverdueAmount(String companyId) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/overdue-amount');
    } catch (e) {
      throw Exception('Failed to get total overdue amount: $e');
    }
  }

  Future<Response> getInvoiceByNumber(String companyId, String invoiceNumber) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/by-number/$invoiceNumber');
    } catch (e) {
      throw Exception('Failed to get invoice by number: $e');
    }
  }

  Future<Response> getInvoicesByDateRange(String companyId, String startDate, String endDate) async {
    try {
      return await _dio.get('/companies/$companyId/invoices/by-date-range', queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      });
    } catch (e) {
      throw Exception('Failed to get invoices by date range: $e');
    }
  }

  // Orders
  Future<Response> getAllOrders(String companyId, {
    String? status,
    String? clientId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      return await _dio.get('/companies/$companyId/orders', queryParameters: {
        'status': status,
        'clientId': clientId,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  Future<Response> createOrder(String companyId, Map<String, dynamic> orderData) async {
    try {
      return await _dio.post('/companies/$companyId/orders', data: orderData);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<Response> getOrderById(String companyId, String id) async {
    try {
      return await _dio.get('/companies/$companyId/orders/$id');
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  Future<Response> updateOrder(String companyId, String id, Map<String, dynamic> orderData) async {
    try {
      return await _dio.put('/companies/$companyId/orders/$id', data: orderData);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<Response> deleteOrder(String companyId, String id) async {
    try {
      return await _dio.delete('/companies/$companyId/orders/$id');
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<Response> updateOrderStatus(String companyId, String id, String status) async {
    try {
      return await _dio.post('/companies/$companyId/orders/$id/status/$status');
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<Response> addOrderItem(String companyId, String orderId, Map<String, dynamic> itemData) async {
    try {
      return await _dio.post('/companies/$companyId/orders/$orderId/items', data: itemData);
    } catch (e) {
      throw Exception('Failed to add order item: $e');
    }
  }

  Future<Response> removeOrderItem(String companyId, String orderId, String itemId) async {
    try {
      return await _dio.delete('/companies/$companyId/orders/$orderId/items/$itemId');
    } catch (e) {
      throw Exception('Failed to remove order item: $e');
    }
  }

  Future<Response> searchOrders(String companyId, String orderNumber, {int page = 0, int size = 10}) async {
    try {
      return await _dio.get('/companies/$companyId/orders/search', queryParameters: {
        'orderNumber': orderNumber,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  Future<Response> calculateOrderRevenue(String companyId, String startDate, String endDate) async {
    try {
      return await _dio.get('/companies/$companyId/orders/revenue', queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      });
    } catch (e) {
      throw Exception('Failed to calculate order revenue: $e');
    }
  }

  Future<Response> getOrdersByDateRange(String companyId, String startDate, String endDate) async {
    try {
      return await _dio.get('/companies/$companyId/orders/by-date-range', queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      });
    } catch (e) {
      throw Exception('Failed to get orders by date range: $e');
    }
  }

  // Measurements
  Future<Response> getMeasurementById(String id) async {
    try {
      return await _dio.get('/v1/measurements/$id');
    } catch (e) {
      throw Exception('Failed to get measurement: $e');
    }
  }

  Future<Response> updateMeasurement(String id, Map<String, dynamic> measurementData) async {
    try {
      return await _dio.put('/v1/measurements/$id', data: measurementData);
    } catch (e) {
      throw Exception('Failed to update measurement: $e');
    }
  }

  Future<Response> deleteMeasurement(String id) async {
    try {
      return await _dio.delete('/v1/measurements/$id');
    } catch (e) {
      throw Exception('Failed to delete measurement: $e');
    }
  }

  Future<Response> createMeasurement(Map<String, dynamic> measurementData) async {
    try {
      return await _dio.post('/v1/measurements', data: measurementData);
    } catch (e) {
      throw Exception('Failed to create measurement: $e');
    }
  }

  Future<Response> searchMeasurements(String clientId, String query) async {
    try {
      return await _dio.get('/v1/measurements/search', queryParameters: {
        'clientId': clientId,
        'query': query,
      });
    } catch (e) {
      throw Exception('Failed to search measurements: $e');
    }
  }

  Future<Response> getMeasurementsByClientId(String clientId) async {
    try {
      return await _dio.get('/v1/measurements/client/$clientId');
    } catch (e) {
      throw Exception('Failed to get measurements by client id: $e');
    }
  }

  Future<Response> deleteMeasurementForClient(String id, String clientId) async {
    try {
      return await _dio.delete('/v1/measurements/$id/client/$clientId');
    } catch (e) {
      throw Exception('Failed to delete measurement for client: $e');
    }
  }

  Future<Response> getCompanyMeasurements(String id) async {
    try {
      return await _dio.get('/companies/$id/measurements');
    } catch (e) {
      throw Exception('Failed to get company measurements: $e');
    }
  }

  Future<Response> searchCompanyMeasurements(String id, String query) async {
    try {
      return await _dio.get('/companies/$id/measurements/search', queryParameters: {
        'query': query,
      });
    } catch (e) {
      throw Exception('Failed to search company measurements: $e');
    }
  }

  Future<Response> countCompanyMeasurements(String id) async {
    try {
      return await _dio.get('/companies/$id/measurements/count');
    } catch (e) {
      throw Exception('Failed to count company measurements: $e');
    }
  }

  // Users
  Future<Response> getAllUsers({String? companyId, int page = 0, int size = 10}) async {
    try {
      return await _dio.get('/users', queryParameters: {
        'companyId': companyId,
        'page': page,
        'size': size,
      });
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<Response> getUserById(String id) async {
    try {
      return await _dio.get('/users/$id');
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<Response> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      return await _dio.put('/users/$id', data: userData);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<Response> deleteUser(String id) async {
    try {
      return await _dio.delete('/users/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      return await _dio.get('/users/me');
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<Response> activateUser(String id) async {
    try {
      return await _dio.post('/users/$id/activate');
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  Future<Response> deactivateUser(String id) async {
    try {
      return await _dio.post('/users/$id/deactivate');
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  Future<Response> changePassword(String id, String newPassword) async {
    try {
      return await _dio.post('/users/$id/change-password', queryParameters: {
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
