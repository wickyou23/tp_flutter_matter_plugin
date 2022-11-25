import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_dimmer_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

const tpControlErrorKey = 'ControlErrorKey';
const tpControlSuccessKey = 'ControlSuccessKey';
const tpReportEventKey = 'ReportEventKey';
const tpReportErrorEventKey = 'ReportErrorEventKey';

class MethodChannelTpLightbuldDimmerDevice
    extends TpLightbuldDimmerDevicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(tpLightbuldChannelDomain);
  final eventChannel = const EventChannel(tpLightbuldEventChannelDomain);
  final Map<String, TpLightbuldControlCompleted> _controlComlepted = {};

  MethodChannelTpLightbuldDimmerDevice() {
    eventChannel.receiveBroadcastStream().listen(_onControlEvent);
  }

  @override
  Future<bool> turnON(
      TPDevice device, TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(device.deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result = await methodChannel.invokeMethod<bool>(
        'turnON', {'deviceId': device.deviceId, 'endpoint': device.endpoint});
    return result!;
  }

  @override
  Future<bool> turnOFF(
      TPDevice device, TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(device.deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result = await methodChannel.invokeMethod<bool>(
        'turnOFF', {'deviceId': device.deviceId, 'endpoint': device.endpoint});
    return result!;
  }

  @override
  Future<bool> controlLevel(TPDevice device, int level,
      TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(device.deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result = await methodChannel.invokeMethod<bool>('controlLevel', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'level': min(level, 100)
    });
    return result!;
  }

  @override
  Future<bool> subscriptionWithDeviceId(TPDevice device) async {
    final result = await methodChannel.invokeMethod<bool>(
        'subscribeWithDeviceId', {'deviceId': device.deviceId});
    return result!;
  }

  @override
  Future<bool> controlTemperatureColorWithDevice(
      TPDevice device,
      int temperatureColor,
      TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(device.deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result =
        await methodChannel.invokeMethod<bool>('controlTemperatureColor', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'temperatureColor': temperatureColor,
    });
    return result!;
  }

  @override
  Future<bool> controlHueAndSaturationColorWithDevice(TPDevice device, int hue,
      int saturation, TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(device.deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result =
        await methodChannel.invokeMethod<bool>('controlHUEAndSaturationColor', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'hue': hue,
      'saturation': saturation,
    });
    return result!;
  }

  void _onControlEvent(dynamic event) {
    if (event is Map) {
      if (event.containsKey(tpControlSuccessKey)) {
        Map successMap = event[tpControlSuccessKey] as Map;
        String deviceId = (successMap['deviceId'] as String?) ?? '';
        if (deviceId.isNotEmpty) {
          final completed = _controlComlepted.remove(deviceId);
          completed?.call(null);
        }
      } else if (event.containsKey(tpControlErrorKey)) {
        Map errorMap = event[tpControlErrorKey] as Map;
        String deviceId = (errorMap['deviceId'] as String?) ?? '';
        String errorMessage = (errorMap['errorMessage'] as String?) ?? '';
        if (deviceId.isNotEmpty) {
          final completed = _controlComlepted.remove(deviceId);
          completed?.call(LightbuldError(errorMessage));
        }
      } else if (event.containsKey(tpReportEventKey)) {
        final map = event[tpReportEventKey] as Map;
        final deviceId = map['deviceId'] as String? ?? '';
        final dataMap = map['data'] as Map? ?? {};

        if (dataMap.containsKey('isOn')) {
          final isOn = dataMap['isOn'] as bool? ?? false;
          TPDeviceEventManager.shared
              .addEvent(TPLightbudDimmerEventSuccess(deviceId, isOn: isOn));
        } else if (dataMap.containsKey('level')) {
          final level = dataMap['level'] as int? ?? 0;
          TPDeviceEventManager.shared
              .addEvent(TPLightbudDimmerEventSuccess(deviceId, level: level));
        } else if (dataMap.containsKey('temperatureColor')) {
          final temperatureColor = dataMap['temperatureColor'] as int? ?? 0;
          TPDeviceEventManager.shared.addEvent(TPLightbudDimmerEventSuccess(
              deviceId,
              temperatureColor: temperatureColor));
        } else if (dataMap.containsKey('hue')) {
          final hue = dataMap['hue'] as int? ?? 0;
          TPDeviceEventManager.shared
              .addEvent(TPLightbudDimmerEventSuccess(deviceId, hue: hue));
        } else if (dataMap.containsKey('saturation')) {
          final saturation = dataMap['saturation'] as int? ?? 0;
          TPDeviceEventManager.shared.addEvent(
              TPLightbudDimmerEventSuccess(deviceId, saturation: saturation));
        } else if (dataMap.containsKey('sensorDetected')) {
          final sensorDetected = dataMap['sensorDetected'] as int? ?? 0;
          TPDeviceEventManager.shared.addEvent(TPLightbudDimmerEventSuccess(
            deviceId,
            sensorDetected: sensorDetected != 0 ? true : false,
          ));
        } else {}
      }
    }
  }
}
