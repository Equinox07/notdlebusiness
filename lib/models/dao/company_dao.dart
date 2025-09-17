
import 'package:floor/floor.dart';
import 'package:notdle/models/company.dart';

@dao
abstract class CompanyDao{

  @Query('SELECT * FROM companies LIMIT 1')
  Future<Company?> getCompany();

  @Query("SELECT * FROM Company")
  Future<List<Company>> findAllCompanies();

  @Query("SELECT * FROM Company WHERE id=:id")
  Future<Company?> findCompanyById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertCompany(Company company);

  @update
  Future<void> updateCompany(Company company);

  @Query('SELECT * FROM company WHERE email = :email LIMIT 1')
  Future<Company?> getCompanyByEmail(String email);

  @Query('SELECT * FROM company WHERE mobile = :mobile LIMIT 1')
  Future<Company?> getCompanyByMobile(String mobile);

  @Query('SELECT * FROM company WHERE mobile = :mobile AND email= :password LIMIT 1')
  Future<Company?> getCompanyByEmailAndMobile(String mobile, String password);

  // @Query('SELECT * FROM company WHERE id = :id')
  // Future<Company?> getCompanyById(String id);

}