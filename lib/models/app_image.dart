import 'package:floor/floor.dart';

@Entity(tableName: 'app_images')
class AppImage {
  @primaryKey
  final String id;

  final String localPath;
  final String? cloudUrl;

  final String ownerId; // ID of User / Order / etc
  final String ownerType; // user, order, chatMessage...

  final String syncStatus; // pending, uploading, completed
  final DateTime createdAt;

  AppImage({
    required this.id,
    required this.localPath,
    this.cloudUrl,
    required this.ownerId,
    required this.ownerType,
    required this.syncStatus,
    required this.createdAt,
  });
}
