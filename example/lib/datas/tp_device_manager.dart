import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_storage_data.dart';

class TPDeviceManager {
  static final _shared = TPDeviceManager._internal();

  TPDeviceManager._internal();

  factory TPDeviceManager() {
    _shared._deviceEvent =
        TPDeviceEventManager.shared.listenEvent(_shared._onDeviceEvent);
    return _shared;
  }

  final storage = TPLocalStorageData();
  late StreamSubscription _deviceEvent;

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

  Future<void> updateDevice(TPDevice device) async {
    _mapDevices.update(
      device.deviceId,
      (value) => device,
      ifAbsent: () => device,
    );

    await storage.saveDevices(_mapDevices);

    final deviceValue = _mapDeviceValues[device.deviceId];
    deviceValue?.value = device.copyWith();
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
        final newDevice = TPDevice(
            deviceId, deviceId, TPDeviceType.kUnknown, DateTime.now(), false);
        syncDevices.update(
          deviceId,
          (value) => newDevice.toJson(),
          ifAbsent: () => newDevice.toJson(),
        );
      }
    }

    syncDevices.forEach((key, value) {
      final device = TPDevice.getDeviceByType(value);
      device.subscribeDevice();

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

    if (event is TPLightbudEventSuccess) {
      final device = deviceValue.value as TPLightbulbDimmer;
      deviceValue.value = device.copyWith(isOn: event.isOn);
    }
  }

  void cancel() {
    _deviceEvent.cancel();
  }
}

extension TPDeviceExt on TPDevice {
  AssetImage getIcon() {
    final device = this;
    if (device is TPLightbulbDimmer) {
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
    } else {
      return '';
    }
  }
}
