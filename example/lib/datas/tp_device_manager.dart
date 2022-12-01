import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_storage_data.dart';

class TPDeviceManager {
  static final _shared = TPDeviceManager._internal();

  TPDeviceManager._internal();

  factory TPDeviceManager() {
    _shared._deviceEvent ??=
        TPDeviceEventManager.shared.listenEvent(_shared._onDeviceEvent);
    return _shared;
  }

  final storage = TPLocalStorageData();
  StreamSubscription? _deviceEvent;

  List<ValueNotifier<TPDevice>> _devices = [];
  List<ValueNotifier<TPDevice>> get devices => _devices;

  final Map<String, TPDevice> _mapDevices = {};
  final Map<String, ValueNotifier<TPDevice>> _mapDeviceValues = {};

  Future<void> addAndSaveDevice(TPDevice device) async {
    if (_mapDevices.containsKey(device.deviceId)) {
      return;
    }

    final valueDevice = ValueNotifier<TPDevice>(device);
    _devices.add(valueDevice);
    _mapDeviceValues.update(
      device.deviceId,
      (value) => valueDevice,
      ifAbsent: () => valueDevice,
    );

    _mapDevices.update(
      device.deviceId,
      (value) => device,
      ifAbsent: () => device,
    );

    await storage.saveDevices(_mapDevices);
  }

  Future<void> updateDevice(TPDevice device, {bool needToNotify = true}) async {
    _mapDevices.update(
      device.deviceId,
      (value) => device,
      ifAbsent: () => device,
    );

    await storage.saveDevices(_mapDevices);

    final deviceValue = _mapDeviceValues[device.deviceId];
    if (needToNotify) {
      final newDeviceInstance = device.copyWith()
        ..deviceError = device.deviceError;
      deviceValue?.value = newDeviceInstance;
    }
  }

  Future<void> removeDevice(String deviceId) async {
    _mapDevices.remove(deviceId);
    _mapDeviceValues.remove(deviceId);
    _devices.removeWhere((element) => element.value.deviceId == deviceId);
    await storage.saveDevices(_mapDevices);
  }

  Future<List<ValueNotifier<TPDevice>>> getAndSyncDevice(
      List<String> newDevices) async {
    final Map<String, dynamic> mapDevices = storage.getDevices();
    final Map<String, dynamic> syncDevices = {};
    for (var deviceId in newDevices) {
      if (mapDevices.containsKey(deviceId)) {
        syncDevices.update(deviceId, (value) => mapDevices[deviceId],
            ifAbsent: () => mapDevices[deviceId]);
      } else {
        final newDevice = TPDevice(deviceId, deviceId, TPDeviceType.kUnknown,
            DateTime.now(), 0, {}, false, {});
        syncDevices.update(
          deviceId,
          (value) => newDevice.toJson(),
          ifAbsent: () => newDevice.toJson(),
        );
      }
    }

    syncDevices.forEach((key, value) {
      final device = TPDevice.getDeviceByType(value);
      try {
        device.subscribeDevice();
      } catch (e) {
        debugPrint(e.toString());
      }

      _mapDevices.update(key, (_) => device, ifAbsent: () => device);
      _mapDeviceValues.update(
        key,
        (_) => ValueNotifier<TPDevice>(device),
        ifAbsent: () => ValueNotifier<TPDevice>(device),
      );
    });

    _devices = _mapDeviceValues.values.toList();
    _devices.sort((a, b) => a.value.createdDate.compareTo(b.value.createdDate));

    await storage.saveDevices(_mapDevices);

    return _devices;
  }

  void _onDeviceEvent(TPDeviceEvent? event) {
    if (event == null) return;

    final deviceValue = _mapDeviceValues[event.deviceId];

    if (deviceValue == null) return;

    if (event is TPLightbudDimmerEventSuccess) {
      final device = deviceValue.value as TPLightbulbDimmer;
      final newDevice = device.copyWith(
        isOn: event.isOn,
        level: event.level,
        temperatureColor: event.temperatureColor,
        hue: event.hue,
        saturation: event.saturation,
        sensorDetected: event.sensorDetected,
      )..deviceError = null;
      deviceValue.value = newDevice;
    } else if (event is TPLightbudEventSuccess) {
      final device = deviceValue.value as TPLightbulb;
      final newDevice = device.copyWith(
        isOn: event.isOn,
        sensorDetected: event.sensorDetected,
      )..deviceError = null;
      deviceValue.value = newDevice;
    } else if (event is TPDeviceEventError) {
      _handleDeviceError(deviceValue, event.errorType);
    }

    updateDevice(deviceValue.value, needToNotify: false);
  }

  void _handleDeviceError(
      ValueNotifier<TPDevice> deviceValue, TPDeviceErrorType error) {
    final device = deviceValue.value;
    if (device is TPLightbulbDimmer) {
      final newValue = device.copyWith()..deviceError = error;
      deviceValue.value = newValue;
    } else if (device is TPLightbulb) {
      final newValue = device.copyWith()..deviceError = error;
      deviceValue.value = newValue;
    }
  }

  void cancel() {
    _deviceEvent?.cancel();
  }
}

extension TPDeviceExt on TPDevice {
  String getDeviceName() {
    if (deviceName.isEmpty) {
      return 'Device $deviceId';
    }

    return deviceName;
  }

  AssetImage getIcon() {
    final device = this;
    if (device is TPLightbulbDimmer) {
      return AssetImage(
          'resources/images/lightbulb_led_wide_${device.isOn ? 'on' : 'off'}.png');
    } else if (device is TPLightbulb) {
      return AssetImage(
          'resources/images/lightbulb_${device.isOn ? 'on' : 'off'}.png');
    } else {
      return const AssetImage('resources/images/unknown_device.png');
    }
  }

  String getStatusText() {
    final device = this;
    if (device is TPLightbulbDimmer) {
      return device.isOn ? 'On' : 'Off';
    } else if (device is TPLightbulb) {
      return device.isOn ? 'On' : 'Off';
    } else {
      return '';
    }
  }

  AssetImage getSensorIcon() {
    final device = this;
    if (device is TPLightbulbDimmer) {
      return AssetImage(
          'resources/images/s_sensor_${device.sensorDetected ? 'on' : 'off'}.png');
    } else {
      return const AssetImage('resources/images/unknown_device.png');
    }
  }
}

extension TPDeviceTypeExt on TPDeviceType {
  String getTypeName() {
    switch (this) {
      case TPDeviceType.kLightbulb:
        return 'Lightbulb';
      case TPDeviceType.kLightbulbDimmer:
        return 'Lightbulb Dimmer';
      default:
        return 'Undefine';
    }
  }
}
