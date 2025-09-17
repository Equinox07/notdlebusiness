

import 'package:notdle/models/company.dart';
import 'package:notdle/models/dao/company_dao.dart';

class CompanyRepository {
  final CompanyDao companyDao;

  CompanyRepository({required this.companyDao});

  // Future<List<Company>> getAllCompanies() {
  //   return companyDao.getAllCompanies();
  // }

  Future<void> insertCompany(Company company) {
    return companyDao.insertCompany(company);
  }

  Future<void> updateCompany(Company company) {
    return companyDao.updateCompany(company);
  }

  // Future<void> deleteCompany(Company company) {
  //   return companyDao.deleteCompany(company);
  // }
}
