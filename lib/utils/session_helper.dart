import 'package:flutter/material.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';

class SessionHelper {
  static Future<void> checkCompanySession(BuildContext context) async {
    final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
    final sessionCompany = await SessionManager.getCompany();

    if (sessionCompany != null && sessionCompany.id.isNotEmpty) {
      final companyDao = companyProvider.companyDao;
      final dbCompany = await companyDao.findCompanyById(sessionCompany.id);

      if (dbCompany != null) {
        if (dbCompany.id != sessionCompany.id) {
           _showSessionMismatchDialog(context);
        }
      } else {
         _showNoCompanyAccountDialog(context);
      }
    }
  }

  static void _showSessionMismatchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session Mismatch"),
        content: const Text("Your session data does not match the stored company data. Please log in again."),
        actions: [
          TextButton(
            onPressed: () {
              // Clear session and navigate to login
              SessionManager.clearSession();
              Navigator.of(context).pop();
              AppNavigator.toLogin2();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static void _showNoCompanyAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("No Company Account Found"),
        content: const Text("No company account was found associated with this session. Please register a company to proceed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppNavigator.toRegisterCompany();
            },
            child: const Text("Register"),
          ),
        ],
      ),
    );
  }
}
