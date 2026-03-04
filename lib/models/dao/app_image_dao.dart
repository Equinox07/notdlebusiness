import 'package:floor/floor.dart';
import 'package:notdle/models/app_image.dart';

@dao
abstract class AppImageDao {
  @insert
  Future<void> insertImage(AppImage image);

  @update
  Future<void> updateImage(AppImage image);

  @delete
  Future<void> deleteImage(AppImage image);

  @Query(
    'SELECT * FROM app_images WHERE ownerId = :ownerId AND ownerType = :ownerType',
  )
  Future<List<AppImage>> getImages(String ownerId, String ownerType);

  @Query(
    'DELETE FROM app_images WHERE ownerId = :ownerId AND ownerType = :ownerType',
  )
  Future<void> deleteByOwner(String ownerId, String ownerType);
}
