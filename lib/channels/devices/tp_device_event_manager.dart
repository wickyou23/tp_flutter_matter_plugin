import 'dart:async';

import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_thermostat.dart';

abstract class TPDeviceEvent {
  final String deviceId;
  final int? endpoint;

  TPDeviceEvent(this.deviceId, this.endpoint);
}

class TPDeviceEventError extends TPDeviceEvent {
  final String errorMessage;
  final TPDeviceErrorType errorType;

  TPDeviceEventError(
      super.deviceId, super.endpoint, this.errorType, this.errorMessage);
}

//TPLightbudDimmerEventSuccess

class TPLightbudDimmerEventSuccess extends TPDeviceEvent {
  final bool? isOn;
  final int? level;
  final int? temperatureColor;
  final int? hue;
  final int? saturation;
  final bool? sensorDetected;

  TPLightbudDimmerEventSuccess(
    super.deviceId,
    super.endpoint, {
    this.isOn,
    this.level,
    this.temperatureColor,
    this.hue,
    this.saturation,
    this.sensorDetected,
  });
}

//TPLightbudEventSuccess

class TPLightbudEventSuccess extends TPDeviceEvent {
  final bool? isOn;
  final bool? sensorDetected;

  TPLightbudEventSuccess(
    super.deviceId,
    super.endpoint, {
    this.isOn,
    this.sensorDetected,
  });
}

//TPThermostatEventSuccess

class TPThermostatEventSuccess extends TPDeviceEvent {
  final double? localTemperature;
  final double? absMaxCool;
  final double? absMaxHeat;
  final double? absMinHeat;
  final double? absMinCool;
  final double? maxCool;
  final double? minCool;
  final double? maxHeat;
  final double? minHeat;
  final double? occupiedCooling;
  final double? occupiedHeating;
  final TPThermostatMode? systemMode;

  TPThermostatEventSuccess(
    super.deviceId,
    super.endpoint, {
    this.localTemperature,
    this.absMaxCool,
    this.absMaxHeat,
    this.absMinCool,
    this.absMinHeat,
    this.maxCool,
    this.minCool,
    this.maxHeat,
    this.minHeat,
    this.systemMode,
    this.occupiedCooling,
    this.occupiedHeating,
  });
}

//TPDeviceEventManager

class TPDeviceEventManager {
  static final shared = TPDeviceEventManager._internal();

  TPDeviceEventManager._internal();

  final StreamController<TPDeviceEvent> _event =
      StreamController<TPDeviceEvent>.broadcast();

  StreamSubscription<TPDeviceEvent> listenEvent(
      void Function(TPDeviceEvent?) event) {
    return _event.stream.listen(event);
  }

  void addEvent(TPDeviceEvent deviceEvent) {
    _event.add(deviceEvent);
  }

  TPDeviceEventError getDeviceEventErrorAndSend(Map errorJson,
      {bool needToSend = true}) {
    final deviceId = errorJson['deviceId'] as String? ?? '';
    final errorType = errorJson['errorType'] as int? ?? 0xffffffff;
    final errorMessage = errorJson['errorMessage'] as String? ?? '';
    final endpoint = errorJson['endpoint'] as int?;
    final deviceEventError = TPDeviceEventError(deviceId, endpoint,
        TPDeviceErrorType.fromValue(errorType), errorMessage);
    if (needToSend) {
      addEvent(deviceEventError);
    }

    return deviceEventError;
  }
}
