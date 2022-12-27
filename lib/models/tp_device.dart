import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_device_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightswitch.dart';
import 'package:tp_flutter_matter_package/models/tp_device_thermostat.dart';

enum TPDeviceType {
  kLightbulb(0x0100),
  kLightbulbDimmer(0x0101),
  kSwitch(0x0103),
  kContactSensor(0x0015),
  kDoorLock(0x000A),
  kLightSensor(0x0106),
  kOccupancySensor(0x0107),
  kOutlet(0x010A),
  kColorBulb(0x010C),
  kWindowCovering(0x0202),
  kThermostat(0x0301),
  kTemperatureSensor(0x0302),
  kFlowSensor(0x0306),
  kGenericSwitch(0x000f),
  kUnknown(0xffff);

  const TPDeviceType(this.value);
  final int value;

  static TPDeviceType fromValue(int value) {
    return values.firstWhereOrNull((e) => e.value == value) ??
        TPDeviceType.kUnknown;
  }
}

enum TPDeviceClusterIDType {
  kTPDeviceClusterIDTypeIdentifyID(0x00000003),
  kTPDeviceClusterIDTypeGroupsID(0x00000004),
  kTPDeviceClusterIDTypeScenesID(0x00000005),
  kTPDeviceClusterIDTypeOnOffID(0x00000006),
  kTPDeviceClusterIDTypeOnOffSwitchConfigurationID(0x00000007),
  kTPDeviceClusterIDTypeLevelControlID(0x00000008),
  kTPDeviceClusterIDTypeBinaryInputBasicID(0x0000000F),
  kTPDeviceClusterIDTypePulseWidthModulationID(0x0000001C),
  kTPDeviceClusterIDTypeDescriptorID(0x0000001D),
  kTPDeviceClusterIDTypeBindingID(0x0000001E),
  kTPDeviceClusterIDTypeAccessControlID(0x0000001F),
  kTPDeviceClusterIDTypeActionsID9(0x00000025),
  kTPDeviceClusterIDTypeBasicID(0x00000028),
  kTPDeviceClusterIDTypeOTASoftwareUpdateProviderID(0x00000029),
  kTPDeviceClusterIDTypeOTASoftwareUpdateRequestorID(0x0000002A),
  kTPDeviceClusterIDTypeLocalizationConfigurationID(0x0000002B),
  kTPDeviceClusterIDTypeTimeFormatLocalizationID(0x0000002C),
  kTPDeviceClusterIDTypeUnitLocalizationID(0x0000002D),
  kTPDeviceClusterIDTypePowerSourceConfigurationID(0x0000002E),
  kTPDeviceClusterIDTypePowerSourceID(0x0000002F),
  kTPDeviceClusterIDTypeGeneralCommissioningID(0x00000030),
  kTPDeviceClusterIDTypeNetworkCommissioningID(0x00000031),
  kTPDeviceClusterIDTypeDiagnosticLogsID(0x00000032),
  kTPDeviceClusterIDTypeGeneralDiagnosticsID(0x00000033),
  kTPDeviceClusterIDTypeSoftwareDiagnosticsID(0x00000034),
  kTPDeviceClusterIDTypeThreadNetworkDiagnosticsID(0x00000035),
  kTPDeviceClusterIDTypeWiFiNetworkDiagnosticsID(0x00000036),
  kTPDeviceClusterIDTypeEthernetNetworkDiagnosticsID(0x00000037),
  kTPDeviceClusterIDTypeTimeSynchronizationID(0x00000038),
  kTPDeviceClusterIDTypeBridgedDeviceBasicID(0x00000039),
  kTPDeviceClusterIDTypeSwitchID(0x0000003B),
  kTPDeviceClusterIDTypeAdministratorCommissioningID(0x0000003C),
  kTPDeviceClusterIDTypeOperationalCredentialsID(0x0000003E),
  kTPDeviceClusterIDTypeGroupKeyManagementID(0x0000003F),
  kTPDeviceClusterIDTypeFixedLabelID(0x00000040),
  kTPDeviceClusterIDTypeUserLabelID(0x00000041),
  kTPDeviceClusterIDTypeProxyConfigurationID(0x00000042),
  kTPDeviceClusterIDTypeProxyDiscoveryID(0x00000043),
  kTPDeviceClusterIDTypeProxyValidID(0x00000044),
  kTPDeviceClusterIDTypeBooleanStateID(0x00000045),
  kTPDeviceClusterIDTypeModeSelectID(0x00000050),
  kTPDeviceClusterIDTypeDoorLockID(0x00000101),
  kTPDeviceClusterIDTypeWindowCoveringID(0x00000102),
  kTPDeviceClusterIDTypeBarrierControlID(0x00000103),
  kTPDeviceClusterIDTypePumpConfigurationAndControlID(0x00000200),
  kTPDeviceClusterIDTypeThermostatID(0x00000201),
  kTPDeviceClusterIDTypeFanControlID(0x00000202),
  kTPDeviceClusterIDTypeThermostatUserInterfaceConfigurationID(0x00000204),
  kTPDeviceClusterIDTypeColorControlID(0x00000300),
  kTPDeviceClusterIDTypeBallastConfigurationID(0x00000301),
  kTPDeviceClusterIDTypeIlluminanceMeasurementID(0x00000400),
  kTPDeviceClusterIDTypeTemperatureMeasurementID(0x00000402),
  kTPDeviceClusterIDTypePressureMeasurementID(0x00000403),
  kTPDeviceClusterIDTypeFlowMeasurementID(0x00000404),
  kTPDeviceClusterIDTypeRelativeHumidityMeasurementID(0x00000405),
  kTPDeviceClusterIDTypeOccupancySensingID(0x00000406),
  kTPDeviceClusterIDTypeWakeOnLANID(0x00000503),
  kTPDeviceClusterIDTypeChannelID(0x00000504),
  kTPDeviceClusterIDTypeTargetNavigatorID(0x00000505),
  kTPDeviceClusterIDTypeMediaPlaybackID(0x00000506),
  kTPDeviceClusterIDTypeMediaInputID(0x00000507),
  kTPDeviceClusterIDTypeLowPowerID(0x00000508),
  kTPDeviceClusterIDTypeKeypadInputID(0x00000509),
  kTPDeviceClusterIDTypeContentLauncherID(0x0000050A),
  kTPDeviceClusterIDTypeAudioOutputID(0x0000050B),
  kTPDeviceClusterIDTypeApplicationLauncherID(0x0000050C),
  kTPDeviceClusterIDTypeApplicationBasicID(0x0000050D),
  kTPDeviceClusterIDTypeAccountLoginID(0x0000050E),
  kTPDeviceClusterIDTypeElectricalMeasurementID(0x00000B04),
  kTPDeviceClusterIDTypeTestClusterID(0xFFF1FC05),
  kTPDeviceClusterIDTypeFaultInjectionID(0xFFF1FC06);

  const TPDeviceClusterIDType(this.value);
  final int value;

  static TPDeviceClusterIDType? fromValue(int value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}

enum TPDeviceErrorType {
  kTPSubscribeTimeoutError(0x00000001),
  kTPReportEventError(0x00000002),
  kTPControlTimeoutError(0x00000003),
  kTPControlUnknowError(0x00000004),
  kTPDeviceDisconnectedError(0x00000005),
  kTPDeviceUnknowError(0xffffffff);

  const TPDeviceErrorType(this.value);
  final int value;

  static TPDeviceErrorType fromValue(int value) {
    return values.firstWhereOrNull((e) => e.value == value) ??
        TPDeviceErrorType.kTPDeviceUnknowError;
  }
}

class TPDevice {
  TPDevice(
    this.deviceId,
    this.subDeviceId,
    this.deviceName,
    this.deviceType,
    this.createdDate,
    this.endpoint,
    this.subDevices,
    this.isOn,
    this.metadata, {
    this.bindingDevices = const [],
  });

  TPDevice.fromJson(Map json)
      : deviceId = json['deviceId'] as String,
        subDeviceId = TPDevice.getSubDeviceId(json),
        deviceName = json['deviceName'] as String? ?? '',
        deviceType =
            TPDeviceType.fromValue(json['deviceType'] as int? ?? 0xffff),
        createdDate = json.containsKey('createdDate')
            ? DateTime.fromMillisecondsSinceEpoch(json['createdDate'] as int)
            : DateTime.now(),
        endpoint = json['endpoint'] as int? ?? 0,
        isOn = json['isOn'] as bool? ?? false,
        subDevices = TPDevice.getSubDevicesByDeviceTypes(json),
        deviceError = (json['deviceError'] is int)
            ? TPDeviceErrorType.fromValue(json['deviceError'])
            : null,
        metadata = TPDevice.convertDeviceMetadata(json['metadata']),
        bindingDevices = (json['bindingDevices'] as List?)
                ?.map((e) => TPBindingDevice.fromJson(e as Map))
                .toList() ??
            [] {
    filterDeviceClusters();
  }

  static TPDevice getDeviceByType(Map json) {
    final deviceType =
        TPDeviceType.fromValue(json['deviceType'] as int? ?? 0xffff);
    switch (deviceType) {
      case TPDeviceType.kLightbulbDimmer:
        return TPLightbulbDimmer.fromJson(json);
      case TPDeviceType.kLightbulb:
        return TPLightbulb.fromJson(json);
      case TPDeviceType.kSwitch:
        return TPLightSwitch.fromJson(json);
      case TPDeviceType.kThermostat:
        return TPThermostat.fromJson(json);
      default:
        return TPDevice.fromJson(json);
    }
  }

  static Map<int, TPDevice> getSubDevicesByDeviceTypes(Map json) {
    Map<int, TPDevice> subDevices = {};
    final subDeviceListJson =
        (json['subDevices'] as List?)?.map((e) => e as Map) ?? [];
    for (var subDeviceJson in subDeviceListJson) {
      final subDevice = TPDevice.getDeviceByType(subDeviceJson);
      subDevices.update(subDevice.endpoint, (value) => subDevice,
          ifAbsent: () => subDevice);
    }

    return subDevices;
  }

  static Map<String, dynamic> convertDeviceMetadata(dynamic json) {
    Map jsonMap = {};
    if (json is String) {
      const decode = JsonDecoder();
      jsonMap = decode.convert(json) as Map;
    } else if (json is Map) {
      jsonMap = json;
    }

    return jsonMap.map((key, value) => MapEntry<String, dynamic>(key, value));
  }

  static String? getSubDeviceId(Map json) {
    final subDeviceId = json['subDeviceId'] as String?;
    if (subDeviceId != null) {
      return subDeviceId;
    }

    final deviceId = json['deviceId'] as String?;
    final endpoint = json['endpoint'] as int?;

    if (deviceId != null && endpoint != null && endpoint != 1) {
      return '${deviceId}_$endpoint';
    }

    return null;
  }

  final String deviceId;
  final String? subDeviceId;
  final String deviceName;
  final TPDeviceType deviceType;
  final DateTime createdDate;
  final int endpoint;
  final Map<int, TPDevice> subDevices;
  final Map<String, dynamic> metadata;
  final List<TPBindingDevice> bindingDevices;
  final defaultClusterControllers = {
    TPDeviceClusterIDType.kTPDeviceClusterIDTypeOnOffID
  };

  final defaultClusterActions = {
    TPDeviceClusterIDType.kTPDeviceClusterIDTypeBindingID
  };

  bool isOn;
  Set<TPDeviceClusterIDType> bindingClusterControllers = {};
  Set<TPDeviceClusterIDType> clusterActions = {};
  Set<TPDeviceClusterIDType> clusterControllers = {
    TPDeviceClusterIDType.kTPDeviceClusterIDTypeOnOffID
  };

  bool get isBindingSupported {
    bool isSupport = clusterActions
            .contains(TPDeviceClusterIDType.kTPDeviceClusterIDTypeBindingID) &&
        bindingClusterControllers.isNotEmpty;
    if (!isSupport) {
      for (var subDevice in subDevices.values) {
        isSupport = isSupport ||
            (subDevice.clusterActions.contains(
                    TPDeviceClusterIDType.kTPDeviceClusterIDTypeBindingID) &&
                subDevice.bindingClusterControllers.isNotEmpty);
      }
    }

    return isSupport;
  }

  TPDeviceErrorType? deviceError;
  bool get isError => deviceError != null;

  List<int> get subEndpoints =>
      subDevices.values.map((e) => e.endpoint).toList();

  bool get isMainDevice => subDeviceId == null;
  bool get isONForAllEnpoint {
    bool tmpIsOn = isOn;
    for (var element in subDevices.values) {
      tmpIsOn = tmpIsOn || element.isOn;
    }

    return tmpIsOn;
  }

  bool checkClusterIdExisted(TPDeviceClusterIDType clusterId) {
    final clusterIds = metadata["clusters"] as Map? ?? {};
    return clusterIds.keys.firstWhereOrNull(
            (element) => element == clusterId.value.toString()) !=
        null;
  }

  Future<bool> subscribeDevice() {
    throw UnimplementedError('subscribeDevice() method has not implement');
  }

  Future<TPDeviceControlResponse> turnON() async {
    throw UnimplementedError('turnON() method has not implement');
  }

  Future<TPDeviceControlResponse> turnOFF() async {
    throw UnimplementedError('turnOFF() method has not implement');
  }

  Future<TPDeviceControlResponse> toggle() async {
    if (isOn) {
      return await turnOFF();
    } else {
      return await turnON();
    }
  }

  Stream<TPDeviceControlResponse> turnONSubDevices() async* {
    for (var element in subDevices.values) {
      if (element.runtimeType == TPDevice) {
        continue;
      }

      if (!element.clusterControllers
          .contains(TPDeviceClusterIDType.kTPDeviceClusterIDTypeOnOffID)) {
        continue;
      }

      yield await element.turnON();
    }
  }

  Stream<TPDeviceControlResponse> turnOFFSubDevices() async* {
    for (var element in subDevices.values) {
      if (element.runtimeType == TPDevice) {
        continue;
      }

      if (!element.clusterControllers
          .contains(TPDeviceClusterIDType.kTPDeviceClusterIDTypeOnOffID)) {
        continue;
      }

      yield await element.turnOFF();
    }
  }

  Stream<TPDeviceControlResponse> toggleAll() async* {
    if (runtimeType == TPDevice) {
      return;
    }

    if (isONForAllEnpoint) {
      yield await turnOFF();
      yield* turnOFFSubDevices();
    } else {
      yield await turnON();
      yield* turnONSubDevices();
    }
  }

  Future<bool> unpairDevice() async {
    return await TpMatterDevicePlatform.instance.unpairDeviceById(deviceId);
  }

  Future<void> filterDeviceClusters() async {
    final clusterIds = metadata["clusters"] as Map? ?? {};
    final actions = Set.from(defaultClusterActions);
    final controllers = Set.from(defaultClusterControllers);
    for (String element in clusterIds.keys) {
      final clusterType = TPDeviceClusterIDType.fromValue(int.parse(element));
      if (clusterType == null) continue;

      if (actions.contains(clusterType)) {
        clusterActions.add(clusterType);
        actions.remove(clusterType);
      }

      if (defaultClusterControllers.contains(clusterType)) {
        clusterControllers.add(clusterType);
        controllers.remove(clusterType);
      }

      if (actions.isEmpty && controllers.isEmpty) {
        break;
      }
    }

    final bindingClusterIds = metadata["bindingClusterIds"] as List? ?? [];
    for (int element in bindingClusterIds) {
      final bindingClusterType = TPDeviceClusterIDType.fromValue(element);
      if (bindingClusterType != null) {
        bindingClusterControllers.add(bindingClusterType);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType.value,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'subDevices': subDevices.values.map((e) => e.toJson()).toList(),
      'endpoint': endpoint,
      'isOn': isOn,
      'metadata': metadata.toJsonStr(),
      'bindingDevices': bindingDevices.map((e) => e.toJson()).toList(),
    };

    if (subDeviceId != null) {
      json.update(
        'subDeviceId',
        (value) => subDeviceId,
        ifAbsent: () => subDeviceId,
      );
    }

    if (deviceError != null) {
      json.update(
        'deviceError',
        (value) => deviceError!.value,
        ifAbsent: () => deviceError!.value,
      );
    }

    return json;
  }

  TPDevice copyWith({
    String? deviceName,
    TPDeviceType? deviceType,
    DateTime? createdDate,
    bool? isOn,
    Map<String, dynamic>? metadata,
    List<TPBindingDevice>? bindingDevices,
  }) {
    return TPDevice(
      deviceId,
      subDeviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      endpoint,
      subDevices,
      isOn ?? this.isOn,
      metadata ?? this.metadata,
      bindingDevices: bindingDevices ?? this.bindingDevices,
    )
      ..deviceError = deviceError
      ..clusterActions = clusterActions
      ..clusterControllers = clusterControllers
      ..bindingClusterControllers = bindingClusterControllers;
  }
}

extension MapExt on Map {
  String toJsonStr() {
    String jsonStr = '{';
    int index = 0;
    forEach((key, value) {
      if (value is Map) {
        jsonStr += '"${key.toString()}": ${value.toJsonStr()}';
      } else {
        const encode = JsonEncoder();
        jsonStr += '"${key.toString()}": ${encode.convert(value)}';
      }

      if (index != length - 1) {
        jsonStr += ',';
      }

      index += 1;
    });

    return jsonStr += '}';
  }
}
