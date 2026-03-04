import 'dart:io';
import 'package:notdle/models/app_image.dart';
import 'package:notdle/models/dao/app_image_dao.dart';
import 'package:notdle/services/image_storage_service.dart';
import 'package:uuid/uuid.dart';

class ImageRepository {
  final AppImageDao dao;
  final ImageStorageService storage;
  final _uuid = const Uuid();

  ImageRepository(this.dao, this.storage);

  /// One-to-One override
  Future<void> saveSingleImage({
    required String ownerId,
    required String ownerType,
    required File file,
  }) async {
    final existing = await dao.getImages(ownerId, ownerType);

    // Delete old DB records + files
    for (var image in existing) {
      await storage.deleteFile(image.localPath);
    }

    await dao.deleteByOwner(ownerId, ownerType);

    final localPath = await storage.saveImage(file);

    final image = AppImage(
      id: _uuid.v4(),
      localPath: localPath,
      ownerId: ownerId,
      ownerType: ownerType,
      syncStatus: 'pending',
      createdAt: DateTime.now(),
    );

    await dao.insertImage(image);
  }

  /// One-to-Many
  Future<void> saveMultipleImage({
    required String ownerId,
    required String ownerType,
    required File file,
  }) async {
    final localPath = await storage.saveImage(file);

    final image = AppImage(
      id: _uuid.v4(),
      localPath: localPath,
      ownerId: ownerId,
      ownerType: ownerType,
      syncStatus: 'pending',
      createdAt: DateTime.now(),
    );

    await dao.insertImage(image);
  }

  Future<List<AppImage>> getImages(String ownerId, String ownerType) {
    return dao.getImages(ownerId, ownerType);
  }
}
