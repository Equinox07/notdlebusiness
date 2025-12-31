import 'package:floor/floor.dart';
import 'package:notdle/models/measurement.dart';

@dao
abstract class MeasurementDao {
  @Query('SELECT * FROM measurements ORDER BY createdDate ASC')
  Future<List<Measurement>> getAllMeasurements();

  @Query('SELECT * FROM measurements WHERE id = :id')
  Future<Measurement?> getById(String id);

  @Query(
    'SELECT * FROM measurements WHERE customerId = :customerId ORDER BY createdDate ASC',
  )
  Future<List<Measurement>> getMeasurementsForCustomer(String customerId);

  // @Insert(onConflict: OnConflictStrategy.replace)
  // Future<int> insertMeasurement(Measurement measurement);

  // @update
  // Future<void> updateMeasurement(Measurement measurement);
  //
  // @delete
  // Future<void> deleteMeasurement(Measurement measurement);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertMeasurement(Measurement measurement);

  @Query('SELECT * FROM measurements WHERE customerId = :customerId')
  Future<List<Measurement>> getMeasurementsByCustomerId(String customerId);

  @Query('SELECT * FROM measurements WHERE id = :id')
  Future<Measurement?> getMeasurementById(String id);

  @update
  Future<void> updateMeasurement(Measurement measurement);

  @delete
  Future<void> deleteMeasurement(Measurement measurement);

  @Query('DELETE FROM measurements WHERE customerId = :customerId')
  Future<void> deleteMeasurementsByCustomerId(String customerId);
}
