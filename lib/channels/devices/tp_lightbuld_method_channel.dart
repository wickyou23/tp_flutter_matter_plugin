import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_interface.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

const tpControlErrorKey = 'ControlErrorKey';
const tpControlSuccessKey = 'ControlSuccessKey';
const tpReportEventKey = 'ReportEventKey';
const tpReportErrorEventKey = 'ReportErrorEventKey';

class MethodChannelTpLightbuldDevice extends TpLightbuldDevicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(tpLightbuldChannelDomain);
  final eventChannel = const EventChannel(tpLightbuldEventChannelDomain);
  final Map<String, TpLightbuldControlCompleted> _controlComlepted = {};

  MethodChannelTpLightbuldDevice() {
    eventChannel.receiveBroadcastStream().listen(_onControlEvent);
  }

  @override
  Future<bool> turnON(
      String deviceId, TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result = await methodChannel
        .invokeMethod<bool>('turnON', {'deviceId': deviceId});
    return result!;
  }

  @override
  Future<bool> turnOFF(
      String deviceId, TpLightbuldControlCompleted controlCompleted) async {
    _controlComlepted.update(deviceId, (value) => controlCompleted,
        ifAbsent: () => controlCompleted);
    final result = await methodChannel
        .invokeMethod<bool>('turnOFF', {'deviceId': deviceId});
    return result!;
  }

  @override
  Future<bool> subscriptionWithDeviceId(String deviceId) async {
    final result = await methodChannel
        .invokeMethod<bool>('subscriptionWithDeviceId', {'deviceId': deviceId});
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
        final isOn = dataMap['isOn'] as bool? ?? false;

        TPDeviceEventManager.shared
            .addEvent(TPLightbudEventSuccess(deviceId, isOn));
      }
    }
  }
}
