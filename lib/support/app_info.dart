import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class DeviceInfo {
  String name;
  String version;
  String id;
  String platform;
}

class AppInfo {

  static String sid = "";

  static Future<DeviceInfo> getDeviceInfo () async {
    DeviceInfo deviceInfo = new DeviceInfo();

    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceInfo.name = build.model;
        deviceInfo.version = build.version.codename;
        deviceInfo.id = build.androidId;
        deviceInfo.platform = "Android";
      } else if (Platform.isIOS) {
        var build = await deviceInfoPlugin.iosInfo;
        deviceInfo.name = build.model;
        deviceInfo.version = build.systemVersion;
        deviceInfo.id = build.identifierForVendor;
        deviceInfo.platform = "iOS";
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

    return deviceInfo;
  }
}