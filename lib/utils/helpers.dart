import 'dart:math';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
String generateInvoiceNumber() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(Iterable.generate(
    15,
    (_) => chars.codeUnitAt(random.nextInt(chars.length)),
  ));
}

String generateOrderNumber() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(Iterable.generate(
    15,
    (_) => chars.codeUnitAt(random.nextInt(chars.length)),
  ));
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

