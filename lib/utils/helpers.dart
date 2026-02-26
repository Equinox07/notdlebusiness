import 'dart:math';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
// import 'package:device_imei/device_imei.dart';
// import 'package:permission_handler/permission_handler.dart';

String generateInvoiceNumber() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      15,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

String generateOrderNumber() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      15,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

String generatePaymentReference() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      15,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  // For Android
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    debugPrint(androidInfo.toString());
    return androidInfo.id; // This is the unique ID for Android devices
  }

  // For iOS
  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    debugPrint(iosInfo.toString());
    return iosInfo.identifierForVendor!; // Unique ID for iOS devices
  }

  return "Unknown Device";
}

Future<String?> getDeviceImei() async {
  String? imei;
  // try {
  //   var permission = await Permission.phone.request();
  //   if (permission.isGranted) {
  //     imei = await DeviceImei().getDeviceImei();
  //   }
  // } catch (e) {
  //   debugPrint("Error getting IMEI: $e");
  // }
  return imei;
}
