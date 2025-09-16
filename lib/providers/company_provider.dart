// lib/providers/company_provider.dart

import 'package:flutter/material.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/services/session_manager.dart';

class CompanyProvider with ChangeNotifier {
  Company? _company;

  Company? get company => _company;

  Future<void> fetchCompany() async {
    _company = await SessionManager.getCompany();
    notifyListeners();
  }
}