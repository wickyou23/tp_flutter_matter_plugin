import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightswitch_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

class MethodChannelTpLightSwitchDevice extends TPLightSwitchDevicePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(tpLightSwitchChannelDomain);
  final eventChannel = const EventChannel(tpLightSwitchEventChannelDomain);

  MethodChannelTpLightSwitchDevice() {
    eventChannel.receiveBroadcastStream().listen(_onControlEvent);
  }

  @override
  Future<bool> subscriptionWithDeviceId(TPDevice device) async {
    final result = await methodChannel.invokeMethod<bool>(
        'subscribeWithDeviceId', {'deviceId': device.deviceId});
    return result!;
  }

  void _onControlEvent(dynamic event) {
    if (event is! Map) {
      return;
    }

    if (event.containsKey(tpReportEventKey)) {
      final map = event[tpReportEventKey] as Map;
      final deviceId = map['deviceId'] as String? ?? '';
      final endpoint = map['endpoint'] as int?;
      final dataMap = map['data'] as Map? ?? {};

      if (endpoint == null) {
        return;
      }

      if (dataMap.containsKey('isOn')) {
        final isOn = dataMap['isOn'] as bool? ?? false;
        TPDeviceEventManager.shared
            .addEvent(TPLightbudEventSuccess(deviceId, endpoint, isOn: isOn));
      } else if (dataMap.containsKey('sensorDetected')) {
        final sensorDetected = dataMap['sensorDetected'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(TPLightbudEventSuccess(
            deviceId, endpoint,
            sensorDetected: sensorDetected != 0 ? true : false));
      } else {}
    } else if (event.containsKey(tpReportErrorEventKey)) {
      final map = event[tpReportErrorEventKey] as Map;
      TPDeviceEventManager.shared.getDeviceEventErrorAndSend(map);
    }
  }
}
