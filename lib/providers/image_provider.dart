import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notdle/models/app_image.dart';
import 'package:notdle/models/repository/image_repository.dart';

class AppImageProvider extends ChangeNotifier {
  final ImageRepository repository;

  AppImageProvider({required this.repository});

  Future<void> saveSingleImage(String? id, {
    required String ownerId,
    required String ownerType,
    required File file,
  }) async {
    await repository.saveSingleImage(
      ownerId: ownerId,
      ownerType: ownerType,
      file: file,
    );
    notifyListeners();
  }

  Future<void> saveMultipleImage({
    required String ownerId,
    required String ownerType,
    required File file,
  }) async {
    await repository.saveMultipleImage(
      ownerId: ownerId,
      ownerType: ownerType,
      file: file,
    );
    notifyListeners();
  }

  Future<List<AppImage>> getImages(String ownerId, String ownerType) async {
    return await repository.getImages(ownerId, ownerType);
  }
}
