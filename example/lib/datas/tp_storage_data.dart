import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

const _kDeviceList = 'DeviceList';

class TPLocalStorageData {
  static final _shared = TPLocalStorageData._internal();

  TPLocalStorageData._internal();

  factory TPLocalStorageData() {
    return _shared;
  }

  late SharedPreferences _prefs;

  Future<void> configuration() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> saveDevices(Map<String, TPDevice> devices) async {
    const jsonEncoder = JsonEncoder();
    final json = jsonEncoder
        .convert(devices.map((key, value) => MapEntry(key, value.toJson())));
    return await _prefs.setString(_kDeviceList, json);
  }

  Map<String, dynamic> getDevices() {
    final json = _prefs.getString(_kDeviceList) ?? "{}";
    const jsonDecoder = JsonDecoder();
    final Map<String, dynamic> mapDevices = jsonDecoder.convert(json);
    return mapDevices;
  }
}
