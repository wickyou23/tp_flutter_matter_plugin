import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbulb_dimmer_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

class TPLightbulbDimmer extends TPDevice {
  TPLightbulbDimmer(
    super.deviceId,
    super.subDeviceId,
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
    this.sensorDetected, {
    super.bindingDevices = const [],
  });

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

  bool get isSupportedLevelControl => clusterControllers
      .contains(TPDeviceClusterIDType.kTPDeviceClusterIDTypeLevelControlID);
  bool get isSupportedColorControl => clusterControllers
      .contains(TPDeviceClusterIDType.kTPDeviceClusterIDTypeColorControlID);

  bool? _isSupportedSensorDevice;
  bool get isSupportedSensorDevice {
    _isSupportedSensorDevice ??= checkClusterIdExisted(
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeOccupancySensingID);

    return _isSupportedSensorDevice!;
  }

  @override
  Set<TPDeviceClusterIDType> get defaultClusterControllers => {
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeOnOffID,
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeLevelControlID,
        TPDeviceClusterIDType.kTPDeviceClusterIDTypeColorControlID
      };

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
    List<TPBindingDevice>? bindingDevices,
  }) {
    return TPLightbulbDimmer(
      deviceId,
      subDeviceId,
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
      bindingDevices: bindingDevices ?? this.bindingDevices,
    )
      ..deviceError = deviceError
      ..clusterActions = clusterActions
      ..clusterControllers = clusterControllers
      ..bindingClusterControllers = bindingClusterControllers;
  }
}
