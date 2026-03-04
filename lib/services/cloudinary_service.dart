import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:notdle/models/app_image.dart';
import 'package:notdle/models/dao/app_image_dao.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;
  final AppImageDao dao;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    required this.dao,
  });

  Future<Map<String, dynamic>?> uploadImage(File file, String folder) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..fields['folder'] = folder
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      return responseData;
    }

    return null;
  }

  // Future<void> syncImage(AppImage image) async {
  //   final file = File(image.localPath);

  //   image = AppImage(
  //     id: image.id,
  //     localPath: image.localPath,
  //     ownerId: image.ownerId,
  //     ownerType: image.ownerType,
  //     syncStatus: "uploading",
  //     createdAt: image.createdAt,
  //   );

  //   await dao.updateImage(image);

  //   final result = await cloudinary.uploadImage(
  //     file,
  //     "images/${image.ownerType}/${image.ownerId}",
  //   );

  //   if (result != null) {
  //     final updated = AppImage(
  //       id: image.id,
  //       localPath: image.localPath,
  //       cloudUrl: result['secure_url'],
  //       publicId: result['public_id'],
  //       ownerId: image.ownerId,
  //       ownerType: image.ownerType,
  //       syncStatus: "completed",
  //       createdAt: image.createdAt,
  //     );

  //     await dao.updateImage(updated);
  //   } else {
  //     image = AppImage(
  //       id: image.id,
  //       localPath: image.localPath,
  //       ownerId: image.ownerId,
  //       ownerType: image.ownerType,
  //       syncStatus: "failed",
  //       createdAt: image.createdAt,
  //     );

  //     await dao.updateImage(image);
  //   }
  // }
}
