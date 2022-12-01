import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbulb_dimmer_method_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

class TPLightbulbDimmer extends TPDevice {
  TPLightbulbDimmer(
    super.deviceId,
    super.deviceName,
    super.deviceType,
    super.createdDate,
    super.endpoint,
    super.subDevices,
    super.isOn,
    super.metadata,
    this.level,
    this.temperatureColor,
    this.hue,
    this.saturation,
    this.sensorDetected,
  );

  TPLightbulbDimmer.fromJson(Map json)
      : level = json['level'] as int? ?? 0,
        temperatureColor = json['temperatureColor'] as int? ?? 0,
        hue = json['hue'] as int? ?? 0,
        saturation = json['saturation'] as int? ?? 0,
        sensorDetected = json['sensorDetected'] as bool? ?? false,
        super.fromJson(json);

  int level;
  int temperatureColor;
  int hue;
  int saturation;
  bool sensorDetected;

  bool? _isSupportedLevelControl;
  bool get isSupportedLevelControl {
    _isSupportedLevelControl ??= checkClusterIdExisted(
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeLevelControlID);

    return _isSupportedLevelControl!;
  }

  bool? _isSupportedColorControl;
  bool get isSupportedColorControl {
    _isSupportedColorControl ??= checkClusterIdExisted(
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeColorControlID);

    return _isSupportedColorControl!;
  }

  bool? _isSupportedSensorDevice;
  bool get isSupportedSensorDevice {
    _isSupportedSensorDevice ??= checkClusterIdExisted(
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeOccupancySensingID);

    return _isSupportedSensorDevice!;
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({'level': level});
  }

  Future<TPDeviceControlResponse> turnON() async {
    final response =
        await TpLightbulbDimmerDevicePlatform.instance.turnON(this);
    if (response is TPDeviceControlSuccess) {
      isOn = true;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> turnOFF() async {
    final response =
        await TpLightbulbDimmerDevicePlatform.instance.turnOFF(this);
    if (response is TPDeviceControlSuccess) {
      isOn = false;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlLevel(int level) async {
    final response = await TpLightbulbDimmerDevicePlatform.instance
        .controlLevel(this, level);
    if (response is TPDeviceControlSuccess) {
      isOn = true;
      this.level = level;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlTemperatureColor(
      int temperatureColor) async {
    final response = await TpLightbulbDimmerDevicePlatform.instance
        .controlTemperatureColorWithDevice(this, temperatureColor);
    if (response is TPDeviceControlSuccess) {
      isOn = true;
      this.temperatureColor = temperatureColor;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlHueAndSaturationColor(
      int hue, int saturation) async {
    final response = await TpLightbulbDimmerDevicePlatform.instance
        .controlHueAndSaturationColorWithDevice(this, hue, saturation);
    if (response is TPDeviceControlSuccess) {
      this.hue = hue;
      this.saturation = saturation;
      deviceError = null;
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
    return await TpLightbulbDimmerDevicePlatform.instance
        .subscriptionWithDeviceId(this);
  }

  @override
  TPLightbulbDimmer copyWith({
    String? deviceId,
    String? deviceName,
    TPDeviceType? deviceType,
    DateTime? createdDate,
    bool? isOn,
    int? level,
    int? temperatureColor,
    int? hue,
    int? saturation,
    bool? sensorDetected,
    Map<String, dynamic>? metadata,
  }) {
    return TPLightbulbDimmer(
      deviceId ?? this.deviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      endpoint,
      subDevices,
      isOn ?? this.isOn,
      metadata ?? this.metadata,
      level ?? this.level,
      temperatureColor ?? this.temperatureColor,
      hue ?? this.hue,
      saturation ?? this.saturation,
      sensorDetected ?? this.sensorDetected,
    )..deviceError = deviceError;
  }
}
