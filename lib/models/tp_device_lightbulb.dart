import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

class TPLightbulb extends TPDevice {
  TPLightbulb(
    super.deviceId,
    super.deviceName,
    super.deviceType,
    super.createdDate,
    super.endpoint,
    super.subDevices,
    super.isOn,
    super.metadata,
    this.sensorDetected,
  );

  bool sensorDetected;
  bool? _isSupportedSensorDevice;
  bool get isSupportedSensorDevice {
    _isSupportedSensorDevice ??= checkClusterIdExisted(
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeOccupancySensingID);

    return _isSupportedSensorDevice!;
  }

  TPLightbulb.fromJson(super.json)
      : sensorDetected = json['sensorDetected'] as bool? ?? false,
        super.fromJson();

  Future<TPDeviceControlResponse> turnON() async {
    final response = await TPLightbulbDevicePlatform.instance.turnON(this);
    if (response is TPDeviceControlSuccess) {
      isOn = true;
    }

    return response;
  }

  Future<TPDeviceControlResponse> turnOFF() async {
    final response = await TPLightbulbDevicePlatform.instance.turnON(this);
    if (response is TPDeviceControlSuccess) {
      isOn = false;
    }

    return response;
  }

  Future<TPDeviceControlResponse> toggle() async {
    if (isOn) {
      return await turnOFF();
    } else {
      return await turnON();
    }
  }

  @override
  Future<bool> subscribeDevice() async {
    return await TPLightbulbDevicePlatform.instance
        .subscriptionWithDeviceId(this);
  }

  @override
  TPLightbulb copyWith({
    String? deviceId,
    String? deviceName,
    TPDeviceType? deviceType,
    DateTime? createdDate,
    bool? isOn,
    Map<String, dynamic>? metadata,
    bool? sensorDetected,
  }) {
    return TPLightbulb(
      deviceId ?? this.deviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      endpoint,
      subDevices,
      isOn ?? this.isOn,
      metadata ?? this.metadata,
      sensorDetected ?? this.sensorDetected,
    )..deviceError = deviceError;
  }
}
