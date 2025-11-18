// lib/providers/company_provider.dart


import 'package:flutter/material.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/models/dao/company_dao.dart';
import 'package:notdle/services/session_manager.dart';

class CompanyProvider with ChangeNotifier {

  final CompanyDao companyDao;

  CompanyProvider({required this.companyDao});


  Company? _company;

  Company? get company => _company;

  Future<void> fetchCompany() async {
    _company = await SessionManager.getCompany();
    notifyListeners();
  }


  Future<Company?> getCompanyByEmailAndMobile(String mobile, String password) async {
      return companyDao.getCompanyByEmailAndMobile(mobile, password);
  }

  Future<void> update(Company company) async {
    return companyDao.updateCompany(company);
  }

  Future<Company?> registerCompany(Company newCompany) async {
    // final registered = await repository.registerCompany(newCompany);
    final existingByEmail = await companyDao.getCompanyByEmail(newCompany.email);
    if (existingByEmail != null) {
      throw CompanyAlreadyExistsException("Email already in use.");
    }

    final existingByMobile = await companyDao.getCompanyByMobile(newCompany.mobile);
    if (existingByMobile != null) {
      throw CompanyAlreadyExistsException("Mobile number already in use.");
    }

     Map<String, dynamic> jsonCompany = newCompany.toMap();

    debugPrint("ToRegister $jsonCompany");
   final registered = await companyDao.insertCompany(newCompany);


    debugPrint("registered ${newCompany.id}");

    var saved = await companyDao.findCompanyById(newCompany.id);
   _company = saved;
    notifyListeners();
    return saved;
  }

  Future<void> tryRegisterCompany(BuildContext context, Company newCompany) async {
    try {
      await registerCompany(newCompany);
      // navigate or show success
    } on CompanyAlreadyExistsException catch (e) {
      // Show snackbar, alert, or validation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      // Handle other errors
      debugPrint("Unexpected error: $e");
    }
  }



// Future<void> tryRegisterCompany(BuildContext context, Company newCompany) async {
  //   try {
  //     await repository.registerCompany(newCompany);
  //     // navigate or show success
  //   } on CompanyAlreadyExistsException catch (e) {
  //     // Show snackbar, alert, or validation message
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //       backgroundColor: Colors.red,
  //     ));
  //   } catch (e) {
  //     // Handle other errors
  //     debugPrint("Unexpected error: $e");
  //   }
  // }

}


class CompanyAlreadyExistsException implements Exception {
  final String message;
  CompanyAlreadyExistsException(this.message);

  @override
  String toString() => message;
}


// final CompanyDao companyDao;
//
// CompanyProvider({required this.companyDao});
//
// Company? _company;
// Company? get company => _company;
//
// Future<void> fetchCompany() async {
//   final all = await companyDao.getAllCompanies();
//   _company = all.isNotEmpty ? all.first : null;
//   notifyListeners();
// }
//
// Future<void> saveCompany(Company company) async {
//   await companyDao.insertCompany(company);
//   await fetchCompany();
// }