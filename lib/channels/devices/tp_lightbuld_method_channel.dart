import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

class MethodChannelTpLightbulbDevice extends TPLightbulbDevicePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(tpLightbulbChannelDomain);
  final eventChannel = const EventChannel(tpLightbulbEventChannelDomain);

  MethodChannelTpLightbulbDevice() {
    eventChannel.receiveBroadcastStream().listen(_onControlEvent);
  }

  @override
  Future<TPDeviceControlResponse> turnON(TPDevice device) async {
    final result = await methodChannel.invokeMethod<Map>(
        'turnON', {'deviceId': device.deviceId, 'endpoint': device.endpoint});
    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> turnOFF(TPDevice device) async {
    final result = await methodChannel.invokeMethod<Map>(
        'turnOFF', {'deviceId': device.deviceId, 'endpoint': device.endpoint});
    return TPDeviceControlHelper.handleControlResponse(result);
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
      final dataMap = map['data'] as Map? ?? {};

      if (dataMap.containsKey('isOn')) {
        final isOn = dataMap['isOn'] as bool? ?? false;
        TPDeviceEventManager.shared
            .addEvent(TPLightbudEventSuccess(deviceId, isOn: isOn));
      } else if (dataMap.containsKey('sensorDetected')) {
        final sensorDetected = dataMap['sensorDetected'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(TPLightbudEventSuccess(
          deviceId,
          sensorDetected: sensorDetected != 0 ? true : false,
        ));
      } else {}
    } else if (event.containsKey(tpReportErrorEventKey)) {
      final map = event[tpReportErrorEventKey] as Map;
      TPDeviceEventManager.shared.getDeviceEventErrorAndSend(map);
    }
  }
}
