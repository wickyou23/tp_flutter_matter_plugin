import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_event_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightswitch.dart';
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
  final Map<String, ValueNotifier<TPDevice>> _mapSubDevicesValue = {};

  final _deviceChanged = StreamController<void>.broadcast();
  Stream<void> get deviceListChangedStream => _deviceChanged.stream;
  StreamSink<void> get deviceListChangedSink => _deviceChanged.sink;

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

    _mapSubDevicesValue.addEntries(
      device.subDevices.values.map(
        (e) => MapEntry(e.subDeviceId!, ValueNotifier<TPDevice>(e)),
      ),
    );

    await storage.saveDevices(_mapDevices);
  }

  Future<void> updateDevice(TPDevice device, {bool needToNotify = true}) async {
    TPDevice realDevice = device;
    ValueNotifier<TPDevice>? subDeviceValue;
    if (!realDevice.isMainDevice) {
      realDevice = _mapDevices[realDevice.deviceId]!;
      realDevice.subDevices.update(
        device.endpoint,
        (value) => device,
        ifAbsent: () => device,
      );

      subDeviceValue = _mapSubDevicesValue[device.subDeviceId];
    }

    final deviceValue = _mapDeviceValues[device.deviceId];
    if (needToNotify) {
      realDevice = realDevice.copyWith()..deviceError = device.deviceError;
      deviceValue?.value = realDevice;

      if (subDeviceValue != null) {
        final newSubDeviceInstance = device.copyWith()
          ..deviceError = device.deviceError;
        subDeviceValue.value = newSubDeviceInstance;
      }
    }

    _mapDevices.update(
      realDevice.deviceId,
      (value) => realDevice,
      ifAbsent: () => realDevice,
    );

    await storage.saveDevices(_mapDevices);
  }

  Future<void> removeDevice(String deviceId) async {
    final subDeviceIds = _mapDevices[deviceId]
            ?.subDevices
            .values
            .map((e) => e.subDeviceId)
            .toSet() ??
        {};
    if (subDeviceIds.isNotEmpty) {
      _mapSubDevicesValue
          .removeWhere((key, value) => subDeviceIds.contains(key));
    }

    _mapDevices.remove(deviceId);
    _mapDeviceValues.remove(deviceId);
    _devices.removeWhere((element) => element.value.deviceId == deviceId);
    await storage.saveDevices(_mapDevices);
    deviceListChangedSink.add(null);
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
        final newDevice = TPDevice(deviceId, '${deviceId}_0', deviceId,
            TPDeviceType.kUnknown, DateTime.now(), 0, {}, false, {});
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

      _mapSubDevicesValue.addEntries(
        device.subDevices.values.map(
          (e) => MapEntry(e.subDeviceId!, ValueNotifier<TPDevice>(e)),
        ),
      );
    });

    _devices = _mapDeviceValues.values.toList();
    _devices.sort((a, b) => a.value.createdDate.compareTo(b.value.createdDate));

    await storage.saveDevices(_mapDevices);

    return _devices;
  }

  Future<Map<TPDeviceClusterIDType, List<TPDevice>>>
      getDevicesMappingWithBindingDevice(
          {required TPDevice bindingDevice}) async {
    final Map<TPDeviceClusterIDType, List<TPDevice>> filterDevices = {};
    for (var device in devices) {
      if (device.value.deviceId == bindingDevice.deviceId) {
        continue;
      }

      for (var clusterIdType in bindingDevice.bindingClusterControllers) {
        if (!device.value.clusterControllers.contains(clusterIdType)) {
          continue;
        }

        if (filterDevices.containsKey(clusterIdType)) {
          final List<TPDevice> deviceList = filterDevices[clusterIdType]!;
          deviceList.add(device.value);
        } else {
          final List<TPDevice> deviceList = [device.value];
          filterDevices.update(
            clusterIdType,
            (value) => deviceList,
            ifAbsent: () => deviceList,
          );
        }
      }
    }

    return filterDevices;
  }

  Future<void> saveBindingDevicesWithDevice(
      TPDevice device, List<Map> bindingDevices) async {
    final newDeviceInstance = device.copyWith(
      bindingDevices:
          bindingDevices.map((e) => TPBindingDevice.fromJson(e)).toList(),
    );

    TPDevice rootDevice;
    if (!newDeviceInstance.isMainDevice) {
      rootDevice = _mapDevices[newDeviceInstance.deviceId]!;
      rootDevice.subDevices.update(
        newDeviceInstance.endpoint,
        (value) => newDeviceInstance,
        ifAbsent: () => newDeviceInstance,
      );

      rootDevice = rootDevice.copyWith();
    } else {
      rootDevice = newDeviceInstance;
    }

    _mapDevices.update(
      rootDevice.deviceId,
      (value) => rootDevice,
      ifAbsent: () => rootDevice,
    );

    await storage.saveDevices(_mapDevices);

    final deviceValue = _mapDeviceValues[device.deviceId];
    deviceValue?.value = rootDevice;
  }

  Future<TPDevice> syncBindingDevices(
      TPDevice device, List<TPBindingDevice> newBindingDevices) async {
    final newDeviceInstance = device.copyWith(
      bindingDevices: newBindingDevices,
    );

    TPDevice rootDevice;
    if (!newDeviceInstance.isMainDevice) {
      rootDevice = _mapDevices[newDeviceInstance.deviceId]!;
      rootDevice.subDevices.update(
        newDeviceInstance.endpoint,
        (value) => newDeviceInstance,
        ifAbsent: () => newDeviceInstance,
      );

      rootDevice = rootDevice.copyWith();
    } else {
      rootDevice = newDeviceInstance;
    }

    _mapDevices.update(
      rootDevice.deviceId,
      (value) => rootDevice,
      ifAbsent: () => rootDevice,
    );

    await storage.saveDevices(_mapDevices);

    final deviceValue = _mapDeviceValues[device.deviceId];
    deviceValue?.value = rootDevice;
    return newDeviceInstance;
  }

  ValueNotifier<TPDevice>? getSubDeviceValue(String subDeviceId) {
    return _mapSubDevicesValue[subDeviceId];
  }

  Future<void> _onDeviceEvent(TPDeviceEvent? event) async {
    if (event == null) return;

    final deviceValue = _mapDeviceValues[event.deviceId];

    if (deviceValue == null) return;

    TPDevice? device = deviceValue.value;
    if (event.endpoint != device.endpoint) {
      device = device.subDevices[event.endpoint];
    }

    if (device == null) return;

    late TPDevice newDeviceInstance;
    if (event is TPLightbudDimmerEventSuccess && device is TPLightbulbDimmer) {
      newDeviceInstance = device.copyWith(
        isOn: event.isOn,
        level: event.level,
        temperatureColor: event.temperatureColor,
        hue: event.hue,
        saturation: event.saturation,
        sensorDetected: event.sensorDetected,
      )..deviceError = null;
    } else if (event is TPLightbudEventSuccess && device is TPLightbulb) {
      newDeviceInstance = device.copyWith(
        isOn: event.isOn,
        sensorDetected: event.sensorDetected,
      )..deviceError = null;
    } else if (event is TPDeviceEventError) {
      _handleDeviceError(deviceValue, event.errorType);
      updateDevice(deviceValue.value, needToNotify: false);
      return;
    }

    if (device.isMainDevice) {
      deviceValue.value = newDeviceInstance;
    } else {
      final mainDevice = deviceValue.value;
      deviceValue.value.subDevices.update(
        event.endpoint!,
        (value) => newDeviceInstance,
        ifAbsent: () => newDeviceInstance,
      );

      deviceValue.value = mainDevice.copyWith();
    }

    updateDevice(deviceValue.value, needToNotify: false);
  }

  Future<void> _handleDeviceError(
      ValueNotifier<TPDevice> deviceValue, TPDeviceErrorType error) async {
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
      if (!isMainDevice) {
        final parentDevice = TPDeviceManager()._mapDevices[deviceId];
        return parentDevice!.getDeviceName();
      }

      return 'Device $deviceId';
    }

    return deviceName;
  }

  AssetImage getIcon() {
    final device = this;
    if (device is TPLightbulbDimmer) {
      return AssetImage(
          'resources/images/lightbulb_led_wide_${device.isONForAllEnpoint ? 'on' : 'off'}.png');
    } else if (device is TPLightbulb) {
      return AssetImage(
          'resources/images/lightbulb_${device.isONForAllEnpoint ? 'on' : 'off'}.png');
    } else if (device is TPLightSwitch) {
      return AssetImage(
          'resources/images/lightswitch_${device.isONForAllEnpoint ? 'on' : 'off'}.png');
    } else {
      return const AssetImage('resources/images/unknown_device.png');
    }
  }

  AssetImage getControllerIcon() {
    final device = this;
    if (device is TPLightbulb || device is TPLightSwitch) {
      return AssetImage(
          'resources/images/control_power_${device.isOn ? 'on' : 'off'}.png');
    } else {
      return const AssetImage('resources/images/unknown_device.png');
    }
  }

  String getStatusText() {
    final device = this;
    if (device is TPLightbulbDimmer) {
      return device.isONForAllEnpoint ? 'On' : 'Off';
    } else if (device is TPLightbulb) {
      return device.isONForAllEnpoint ? 'On' : 'Off';
    } else if (device is TPLightSwitch) {
      return device.isONForAllEnpoint ? 'On' : 'Off';
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
      case TPDeviceType.kSwitch:
        return 'Switch';
      default:
        return 'Undefine';
    }
  }
}

extension TPDeviceClusterIDTypeExt on TPDeviceClusterIDType {
  String getTitle() {
    switch (this) {
      case TPDeviceClusterIDType.kTPDeviceClusterIDTypeOnOffID:
        return 'On/Off Control';
      default:
        return '';
    }
  }
}
