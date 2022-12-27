import 'package:collection/collection.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightswitch_method_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_thermostat_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

enum TPThermostatMode {
  off(0),
  auto(1),
  cool(3),
  heat(4),
  emergencyHeating(5),
  precooling(6),
  fanOnly(7);

  const TPThermostatMode(this.value);
  final int value;

  String get title {
    switch (this) {
      case off:
        return 'off';
      case auto:
        return 'auto';
      case cool:
        return 'cool';
      case heat:
        return 'heat';
      case emergencyHeating:
        return 'Heating';
      case precooling:
        return 'Precooling';
      case fanOnly:
        return 'Fan Only';
    }
  }

  static TPThermostatMode? fromValue(int? value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}

class TPThermostat extends TPDevice {
  TPThermostat(
    super.deviceId,
    super.subDeviceId,
    super.deviceName,
    super.deviceType,
    super.createdDate,
    super.endpoint,
    super.subDevices,
    super.isOn,
    super.metadata, {
    this.systemMode = TPThermostatMode.off,
    this.localTempurature,
    this.absMinCool = 16,
    this.absMaxCool = 32,
    this.absMinHeat = 7,
    this.absMaxHeat = 30,
    this.minCool = 16,
    this.maxCool = 32,
    this.minHeat = 7,
    this.maxHeat = 30,
    this.occupiedCooling = 16,
    this.occupiedHeating = 7,
    super.bindingDevices = const [],
  });

  TPThermostatMode systemMode;
  final double? localTempurature;
  final double absMinHeat;
  final double absMaxHeat;
  final double absMinCool;
  final double absMaxCool;
  double minHeat;
  double maxHeat;
  double minCool;
  double maxCool;
  double occupiedCooling;
  double occupiedHeating;

  TPThermostat.fromJson(super.json)
      : systemMode = TPThermostatMode.fromValue(json['systemMode'] as int?) ??
            TPThermostatMode.off,
        localTempurature = json['localTempurature'] as double?,
        absMinHeat = json['absMinHeat'] as double? ?? 7,
        absMaxHeat = json['absMaxHeat'] as double? ?? 30,
        absMinCool = json['absMinCool'] as double? ?? 16,
        absMaxCool = json['absMaxCool'] as double? ?? 32,
        minHeat = json['minHeat'] as double? ?? 7,
        maxHeat = json['maxHeat'] as double? ?? 30,
        minCool = json['minCool'] as double? ?? 16,
        maxCool = json['maxCool'] as double? ?? 32,
        occupiedCooling = json['occupiedCooling'] as double? ?? 16,
        occupiedHeating = json['occupiedHeating'] as double? ?? 7,
        super.fromJson();

  @override
  Future<bool> subscribeDevice() async {
    return await TPThermostatDevicePlatform.instance
        .subscriptionWithDeviceId(this);
  }

  Future<TPDeviceControlResponse> controlSystemMode(
      TPThermostatMode mode) async {
    final response =
        await TPThermostatDevicePlatform.instance.controlSystemMode(this, mode);
    if (response is TPDeviceControlSuccess) {
      systemMode = mode;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlMinCool(double min) async {
    final response =
        await TPThermostatDevicePlatform.instance.controlMinCool(this, min);
    if (response is TPDeviceControlSuccess) {
      minCool = min;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlMaxCool(double max) async {
    final response =
        await TPThermostatDevicePlatform.instance.controlMaxCool(this, max);
    if (response is TPDeviceControlSuccess) {
      maxCool = max;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlMinHeat(double min) async {
    final response =
        await TPThermostatDevicePlatform.instance.controlMinHeat(this, min);
    if (response is TPDeviceControlSuccess) {
      minHeat = min;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlMaxHeat(double max) async {
    final response =
        await TPThermostatDevicePlatform.instance.controlMaxHeat(this, max);
    if (response is TPDeviceControlSuccess) {
      maxHeat = max;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlOccupiedCooling(
      double occupiedCooling) async {
    final response = await TPThermostatDevicePlatform.instance
        .controlOccupiedCooling(this, occupiedCooling);
    if (response is TPDeviceControlSuccess) {
      occupiedCooling = occupiedCooling;
      deviceError = null;
    }

    return response;
  }

  Future<TPDeviceControlResponse> controlOccupiedHeating(
      double occupiedHeating) async {
    final response = await TPThermostatDevicePlatform.instance
        .controlOccupiedHeating(this, occupiedHeating);
    if (response is TPDeviceControlSuccess) {
      occupiedHeating = occupiedHeating;
      deviceError = null;
    }

    return response;
  }

  @override
  bool get isOn => systemMode != TPThermostatMode.off;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'systemMode': systemMode.value,
        'localTempurature': localTempurature,
        'absMinHeat': absMinHeat,
        'absMaxHeat': absMaxHeat,
        'absMinCool': absMinCool,
        'absMaxCool': absMaxCool,
        'minHeat': minHeat,
        'maxHeat': maxHeat,
        'minCool': minCool,
        'maxCool': maxCool,
        'occupiedCooling': occupiedCooling,
        'occupiedHeating': occupiedHeating,
      });
  }

  @override
  TPThermostat copyWith({
    String? deviceName,
    TPDeviceType? deviceType,
    DateTime? createdDate,
    bool? isOn,
    Map<String, dynamic>? metadata,
    bool? sensorDetected,
    List<TPBindingDevice>? bindingDevices,
    TPThermostatMode? systemMode,
    double? localTempurature,
    double? absMinHeat,
    double? absMaxHeat,
    double? absMinCool,
    double? absMaxCool,
    double? minHeat,
    double? maxHeat,
    double? minCool,
    double? maxCool,
    double? occupiedCooling,
    double? occupiedHeating,
  }) {
    return TPThermostat(
      deviceId,
      subDeviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      endpoint,
      subDevices,
      isOn ?? this.isOn,
      metadata ?? this.metadata,
      bindingDevices: bindingDevices ?? this.bindingDevices,
      systemMode: systemMode ?? this.systemMode,
      localTempurature: localTempurature ?? this.localTempurature,
      absMinHeat: absMinHeat ?? this.absMinHeat,
      absMaxHeat: absMaxHeat ?? this.absMaxHeat,
      absMinCool: absMinCool ?? this.absMinCool,
      absMaxCool: absMaxCool ?? this.absMaxCool,
      minHeat: minHeat ?? this.minHeat,
      maxHeat: maxHeat ?? this.maxHeat,
      minCool: minCool ?? this.minCool,
      maxCool: maxCool ?? this.maxCool,
      occupiedCooling: occupiedCooling ?? this.occupiedCooling,
      occupiedHeating: occupiedHeating ?? this.occupiedHeating,
    )
      ..deviceError = deviceError
      ..clusterActions = clusterActions
      ..clusterControllers = clusterControllers
      ..bindingClusterControllers = bindingClusterControllers;
  }
}
