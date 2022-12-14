import 'dart:async';

import 'package:tp_flutter_matter_package/models/tp_device.dart';

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
