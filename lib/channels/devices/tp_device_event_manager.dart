import 'dart:async';

abstract class TPDeviceEvent {
  final String deviceId;

  TPDeviceEvent(this.deviceId);
}

class TPDeviceEventError extends TPDeviceEvent {
  final String errorMessage;

  TPDeviceEventError(super.deviceId, this.errorMessage);
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
    super.deviceId, {
    this.isOn,
    this.level,
    this.temperatureColor,
    this.hue,
    this.saturation,
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
}
