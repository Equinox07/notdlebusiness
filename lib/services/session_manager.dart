
import 'dart:convert';

import 'package:notdle/models/company.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _companyKey = "company_data";


  //Save company data to shared preference
  static Future<void> saveCompany(Company company) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the company object to JSON string
    final companyJson = jsonEncode(company.toMap());
    await prefs.setString(_companyKey, companyJson);
  }

  // Retrieve company data information
  static Future<Company?> getCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final companyJson = prefs.getString(_companyKey);
    if(companyJson != null) {
      // Decode the JSON string back into the Map and create company Obj
      final companyMap = jsonDecode(companyJson);
      return Company.fromMap(companyMap);
    }
    return null;
  }

  // Clear company data on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_companyKey);
  }

}