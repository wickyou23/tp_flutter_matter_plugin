import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_dimmer_method_interface.dart';
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

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({'level': level});
  }

  Future<bool> turnON(TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDimmerDevicePlatform.instance.turnON(this, (p0) {
      if (p0 == null) {
        isOn = true;
      }

      onCompleted(p0);
    });
  }

  Future<bool> turnOFF(TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDimmerDevicePlatform.instance.turnOFF(this, (p0) {
      if (p0 == null) {
        isOn = false;
      }

      onCompleted(p0);
    });
  }

  Future<bool> controlLevel(
      int level, TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDimmerDevicePlatform.instance
        .controlLevel(this, level, (p0) {
      if (p0 == null) {
        isOn = true;
        this.level = level;
      }

      onCompleted(p0);
    });
  }

  Future<bool> controlTemperatureColor(
      int temperatureColor, TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDimmerDevicePlatform.instance
        .controlTemperatureColorWithDevice(this, temperatureColor, (p0) {
      if (p0 == null) {
        this.temperatureColor = temperatureColor;
      }

      onCompleted(p0);
    });
  }

  Future<bool> controlHueAndSaturationColor(
      int hue, int saturation, TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDimmerDevicePlatform.instance
        .controlHueAndSaturationColorWithDevice(this, hue, saturation, (p0) {
      if (p0 == null) {
        this.hue = hue;
        this.saturation = saturation;
      }

      onCompleted(p0);
    });
  }

  Future<bool> toggle(TpLightbuldControlCompleted onCompleted) async {
    if (isOn) {
      return turnOFF(onCompleted);
    } else {
      return turnON(onCompleted);
    }
  }

  @override
  Future<bool> subscribeDevice() async {
    return await TpLightbuldDimmerDevicePlatform.instance
        .subscriptionWithDeviceId(this);
  }

  @override
  TPLightbulbDimmer copyWith(
      {String? deviceId,
      String? deviceName,
      TPDeviceType? deviceType,
      DateTime? createdDate,
      bool? isOn,
      int? level,
      int? temperatureColor,
      int? hue,
      int? saturation,
      bool? sensorDetected}) {
    return TPLightbulbDimmer(
      deviceId ?? this.deviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      endpoint,
      subDevices,
      isOn ?? this.isOn,
      level ?? this.level,
      temperatureColor ?? this.temperatureColor,
      hue ?? this.hue,
      saturation ?? this.saturation,
      sensorDetected ?? this.sensorDetected,
    );
  }
}
