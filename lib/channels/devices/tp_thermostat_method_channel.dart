import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_thermostat_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_thermostat.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

class MethodChannelTPThermostatDevice extends TPThermostatDevicePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(tpThermostatChannelDomain);
  final eventChannel = const EventChannel(tpThermostatEventChannelDomain);

  MethodChannelTPThermostatDevice() {
    eventChannel.receiveBroadcastStream().listen(_onControlEvent);
  }

  @override
  Future<bool> subscriptionWithDeviceId(TPDevice device) async {
    final result = await methodChannel.invokeMethod<bool>(
        'subscribeWithDeviceId', {'deviceId': device.deviceId});
    return result!;
  }

  @override
  Future<TPDeviceControlResponse> controlSystemMode(
      TPDevice device, TPThermostatMode mode) async {
    final result = await methodChannel.invokeMethod<Map>('controlSystemMode', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'systemMode': mode.value,
    });

    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlMinCool(
      TPDevice device, double min) async {
    final result = await methodChannel.invokeMethod<Map>('controlMinCool', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'min': (min * 100).toInt(),
    });

    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlMaxCool(
      TPDevice device, double max) async {
    final result = await methodChannel.invokeMethod<Map>('controlMaxCool', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'max': (max * 100).toInt(),
    });

    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlMinHeat(
      TPDevice device, double min) async {
    final result = await methodChannel.invokeMethod<Map>('controlMinHeat', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'min': (min * 100).toInt(),
    });

    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlMaxHeat(
      TPDevice device, double max) async {
    final result = await methodChannel.invokeMethod<Map>('controlMaxHeat', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'max': (max * 100).toInt(),
    });

    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlOccupiedCooling(
      TPDevice device, double occupiedCooling) async {
    final result =
        await methodChannel.invokeMethod<Map>('controlOccupiedCooling', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'occupiedCooling': (occupiedCooling * 100).toInt(),
    });

    return TPDeviceControlHelper.handleControlResponse(result);
  }

  @override
  Future<TPDeviceControlResponse> controlOccupiedHeating(
      TPDevice device, double occupiedHeating) async {
    final result =
        await methodChannel.invokeMethod<Map>('controlOccupiedHeating', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'occupiedHeating': (occupiedHeating * 100).toInt(),
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

      if (dataMap.containsKey('localTemperature')) {
        final localTemperature = dataMap['localTemperature'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            localTemperature: localTemperature?.matterIntToCelsius()));
      } else if (dataMap.containsKey('systemMode')) {
        final systemMode = dataMap['systemMode'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            systemMode: TPThermostatMode.fromValue(systemMode)));
      } else if (dataMap.containsKey('absMaxCool')) {
        final absMaxCool = dataMap['absMaxCool'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            absMaxCool: absMaxCool?.matterIntToCelsius()));
      } else if (dataMap.containsKey('absMaxHeat')) {
        final absMaxHeat = dataMap['absMaxHeat'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            absMaxHeat: absMaxHeat?.matterIntToCelsius()));
      } else if (dataMap.containsKey('absMinHeat')) {
        final absMinHeat = dataMap['absMinHeat'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            absMinHeat: absMinHeat?.matterIntToCelsius()));
      } else if (dataMap.containsKey('absMinCool')) {
        final absMinCool = dataMap['absMinCool'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            absMinCool: absMinCool?.matterIntToCelsius()));
      } else if (dataMap.containsKey('maxCool')) {
        final maxCool = dataMap['maxCool'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            maxCool: maxCool?.matterIntToCelsius()));
      } else if (dataMap.containsKey('minCool')) {
        final minCool = dataMap['minCool'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            minCool: minCool?.matterIntToCelsius()));
      } else if (dataMap.containsKey('maxHeat')) {
        final maxHeat = dataMap['maxHeat'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            maxHeat: maxHeat?.matterIntToCelsius()));
      } else if (dataMap.containsKey('minHeat')) {
        final minHeat = dataMap['minHeat'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            minHeat: minHeat?.matterIntToCelsius()));
      } else if (dataMap.containsKey('occupiedCooling')) {
        final occupiedCooling = dataMap['occupiedCooling'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            occupiedCooling: occupiedCooling?.matterIntToCelsius()));
      } else if (dataMap.containsKey('occupiedHeating')) {
        final occupiedHeating = dataMap['occupiedHeating'] as int?;
        TPDeviceEventManager.shared.addEvent(TPThermostatEventSuccess(
            deviceId, endpoint,
            occupiedHeating: occupiedHeating?.matterIntToCelsius()));
      } else {}
    } else if (event.containsKey(tpReportErrorEventKey)) {
      final map = event[tpReportErrorEventKey] as Map;
      TPDeviceEventManager.shared.getDeviceEventErrorAndSend(map);
    }
  }
}

extension IntExt on int {
  double matterIntToCelsius() {
    return this / 100;
  }
}
