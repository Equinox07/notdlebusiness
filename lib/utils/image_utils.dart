import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageUtils {
  static Future<String?> saveImagePermanently(
    String imagePath,
    String prefix,
    String id,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final extension = p.extension(imagePath);
      final fileName = '${prefix}_$id$extension';
      final file = File(imagePath);
      final localImage = await file.copy('${directory.path}/$fileName');
      return localImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}
