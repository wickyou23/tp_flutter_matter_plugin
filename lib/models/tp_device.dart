import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';

enum TPDeviceType {
  kLightbulb(0x0100),
  kLightbulbDimmer(0x0101),
  kSwitch(0x0103),
  kContactSensor(0x0015),
  kDoorLock(0x000A),
  kLightSensor(0x0106),
  kOccupancySensor(0x0107),
  kOutlet(0x010A),
  kColorBulb(0x010C),
  kWindowCovering(0x0202),
  kThermostat(0x0301),
  kTemperatureSensor(0x0302),
  kFlowSensor(0x0306),
  kUnknown(0xffff);

  factory TPDeviceType.fromValue(int value) {
    switch (value) {
      case 0x0100:
        return TPDeviceType.kLightbulb;
      case 0x0101:
        return TPDeviceType.kLightbulbDimmer;
      case 0x0103:
        return TPDeviceType.kSwitch;
      case 0x0015:
        return TPDeviceType.kContactSensor;
      case 0x000A:
        return TPDeviceType.kDoorLock;
      case 0x0106:
        return TPDeviceType.kLightSensor;
      case 0x0107:
        return TPDeviceType.kOccupancySensor;
      case 0x010A:
        return TPDeviceType.kOutlet;
      case 0x010C:
        return TPDeviceType.kColorBulb;
      case 0x0202:
        return TPDeviceType.kWindowCovering;
      case 0x0301:
        return TPDeviceType.kThermostat;
      case 0x0302:
        return TPDeviceType.kTemperatureSensor;
      case 0x0306:
        return TPDeviceType.kFlowSensor;
      default:
        return TPDeviceType.kUnknown;
    }
  }

  const TPDeviceType(this.value);
  final int value;
}

class TPDevice {
  TPDevice(this.deviceId, this.deviceName, this.deviceType, this.createdDate,
      this.isOn);

  TPDevice.fromJson(Map json)
      : deviceId = json['deviceId'] as String,
        deviceName = json['deviceName'] as String? ?? '',
        deviceType =
            TPDeviceType.fromValue(json['deviceType'] as int? ?? 0xffff),
        createdDate = json.containsKey('createdDate')
            ? DateTime.fromMillisecondsSinceEpoch(json['createdDate'] as int)
            : DateTime.now(),
        isOn = json['isOn'] as bool? ?? false;

  final String deviceId;
  final String deviceName;
  final TPDeviceType deviceType;
  final DateTime createdDate;

  bool isOn;

  static TPDevice getDeviceByType(Map json) {
    final deviceType =
        TPDeviceType.fromValue(json['deviceType'] as int? ?? 0xffff);
    switch (deviceType) {
      case TPDeviceType.kLightbulbDimmer:
        return TPLightbulbDimmer.fromJson(json);
      default:
        return TPDevice.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType.value,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'isOn': isOn,
    };
  }

  Future<bool> subscribeDevice() {
    throw UnimplementedError('subscribeDevice() method has not implement');
  }

  TPDevice copyWith() {
    throw UnimplementedError('copyWith() method has not implement');
  }
}
