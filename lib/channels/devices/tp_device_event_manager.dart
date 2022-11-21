import 'dart:async';

abstract class TPDeviceEvent {
  final String deviceId;

  TPDeviceEvent(this.deviceId);
}

class TPLightbudEventSuccess extends TPDeviceEvent {
  final bool isOn;

  TPLightbudEventSuccess(super.deviceId, this.isOn);
}

class TPDeviceEventError extends TPDeviceEvent {
  final String errorMessage;

  TPDeviceEventError(super.deviceId, this.errorMessage);
}

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
