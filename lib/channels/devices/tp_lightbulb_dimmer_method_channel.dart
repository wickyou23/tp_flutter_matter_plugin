import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbulb_dimmer_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

class MethodChannelTpLightbulbDimmerDevice
    extends TpLightbulbDimmerDevicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(tpLightbulbDimmerChannelDomain);
  final eventChannel = const EventChannel(tpLightbulbDimmerEventChannelDomain);

  MethodChannelTpLightbulbDimmerDevice() {
    eventChannel.receiveBroadcastStream().listen(_onControlEvent);
  }

  @override
  Future<TPDeviceControlResponse> turnON(TPDevice device) async {
    final result = await methodChannel.invokeMethod<Map>('turnON', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'subEndpoints': device.subEndpoints,
    });
    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> turnOFF(TPDevice device) async {
    final result = await methodChannel.invokeMethod<Map>('turnOFF', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'subEndpoints': device.subEndpoints,
    });
    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlLevel(
      TPDevice device, int level) async {
    final result = await methodChannel.invokeMethod<Map>('controlLevel', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'level': min(level, 100),
      'subEndpoints': device.subEndpoints,
    });
    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<bool> subscriptionWithDeviceId(TPDevice device) async {
    final result = await methodChannel.invokeMethod<bool>(
        'subscribeWithDeviceId', {'deviceId': device.deviceId});
    return result!;
  }

  @override
  Future<TPDeviceControlResponse> controlTemperatureColorWithDevice(
      TPDevice device, int temperatureColor) async {
    final result =
        await methodChannel.invokeMethod<Map>('controlTemperatureColor', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'temperatureColor': temperatureColor,
      'subEndpoints': device.subEndpoints,
    });
    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlHueAndSaturationColorWithDevice(
      TPDevice device, int hue, int saturation) async {
    final result =
        await methodChannel.invokeMethod<Map>('controlHUEAndSaturationColor', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'hue': hue,
      'saturation': saturation,
    });
    return TPDeviceControlHelper.handleControlResponse(result);
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
        TPDeviceEventManager.shared.addEvent(
            TPLightbudDimmerEventSuccess(deviceId, endpoint, isOn: isOn));
      } else if (dataMap.containsKey('level')) {
        final level = dataMap['level'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(
            TPLightbudDimmerEventSuccess(deviceId, endpoint, level: level));
      } else if (dataMap.containsKey('temperatureColor')) {
        final temperatureColor = dataMap['temperatureColor'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(TPLightbudDimmerEventSuccess(
            deviceId, endpoint,
            temperatureColor: temperatureColor));
      } else if (dataMap.containsKey('hue')) {
        final hue = dataMap['hue'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(
            TPLightbudDimmerEventSuccess(deviceId, endpoint, hue: hue));
      } else if (dataMap.containsKey('saturation')) {
        final saturation = dataMap['saturation'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(TPLightbudDimmerEventSuccess(
            deviceId, endpoint,
            saturation: saturation));
      } else if (dataMap.containsKey('sensorDetected')) {
        final sensorDetected = dataMap['sensorDetected'] as int? ?? 0;
        TPDeviceEventManager.shared.addEvent(TPLightbudDimmerEventSuccess(
            deviceId, endpoint,
            sensorDetected: sensorDetected != 0 ? true : false));
      }
    } else if (event.containsKey(tpReportErrorEventKey)) {
      final map = event[tpReportErrorEventKey] as Map;
      TPDeviceEventManager.shared.getDeviceEventErrorAndSend(map);
    }
  }
}
