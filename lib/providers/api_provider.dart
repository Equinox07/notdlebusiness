import 'package:flutter/material.dart';
import 'package:notdle/services/api_service.dart';

class ApiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ApiService get apiService => _apiService;
  
  // You can add any API-related state management here if needed
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
