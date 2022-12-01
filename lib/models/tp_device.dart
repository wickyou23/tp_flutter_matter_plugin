import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb.dart';

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
  kUnknown(0xffff);

  factory TPDeviceType.fromValue(int value) {
    switch (value) {
      case 0x0100:
        return TPDeviceType.kLightbulb;
      case 0x0101:
        return TPDeviceType.kLightbulbDimmer;
      case 0x0103:
        return TPDeviceType.kSwitch;
      case 0x0015:
        return TPDeviceType.kContactSensor;
      case 0x000A:
        return TPDeviceType.kDoorLock;
      case 0x0106:
        return TPDeviceType.kLightSensor;
      case 0x0107:
        return TPDeviceType.kOccupancySensor;
      case 0x010A:
        return TPDeviceType.kOutlet;
      case 0x010C:
        return TPDeviceType.kColorBulb;
      case 0x0202:
        return TPDeviceType.kWindowCovering;
      case 0x0301:
        return TPDeviceType.kThermostat;
      case 0x0302:
        return TPDeviceType.kTemperatureSensor;
      case 0x0306:
        return TPDeviceType.kFlowSensor;
      default:
        return TPDeviceType.kUnknown;
    }
  }

  const TPDeviceType(this.value);
  final int value;
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
}

enum TPDeviceErrorType {
  kTPSubscribeTimeoutError(0x00000001),
  kTPReportEventError(0x00000002),
  kTPControlTimeoutError(0x00000003),
  kTPControlUnknowError(0x00000004),
  kTPDeviceDisconnectedError(0x00000005),
  kTPDeviceUnknowError(0xffffffff);

  factory TPDeviceErrorType.fromValue(int value) {
    switch (value) {
      case 0x00000001:
        return TPDeviceErrorType.kTPSubscribeTimeoutError;
      case 0x00000002:
        return TPDeviceErrorType.kTPReportEventError;
      case 0x00000003:
        return TPDeviceErrorType.kTPControlTimeoutError;
      case 0x00000004:
        return TPDeviceErrorType.kTPControlUnknowError;
      case 0x00000005:
        return TPDeviceErrorType.kTPDeviceDisconnectedError;
      default:
        return TPDeviceErrorType.kTPDeviceUnknowError;
    }
  }

  const TPDeviceErrorType(this.value);
  final int value;
}

class TPDevice {
  TPDevice(this.deviceId, this.deviceName, this.deviceType, this.createdDate,
      this.endpoint, this.subDevices, this.isOn, this.metadata);

  TPDevice.fromJson(Map json)
      : deviceId = json['deviceId'] as String,
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
        metadata = TPDevice.convertDeviceMetadata(json['metadata']);

  static TPDevice getDeviceByType(Map json) {
    final deviceType =
        TPDeviceType.fromValue(json['deviceType'] as int? ?? 0xffff);
    switch (deviceType) {
      case TPDeviceType.kLightbulbDimmer:
        return TPLightbulbDimmer.fromJson(json);
      case TPDeviceType.kLightbulb:
        return TPLightbulb.fromJson(json);
      default:
        return TPDevice.fromJson(json);
    }
  }

  static Map<TPDeviceType, TPDevice> getSubDevicesByDeviceTypes(Map json) {
    Map<TPDeviceType, TPDevice> subDevices = {};
    final subDeviceListJson =
        (json['subDevices'] as List?)?.map((e) => e as Map) ?? [];
    for (var subDeviceJson in subDeviceListJson) {
      final subDevice = TPDevice.fromJson(subDeviceJson);
      subDevices.update(subDevice.deviceType, (value) => subDevice,
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

  final String deviceId;
  final String deviceName;
  final TPDeviceType deviceType;
  final DateTime createdDate;
  final int endpoint;
  final Map<TPDeviceType, TPDevice> subDevices;
  final Map<String, dynamic> metadata;

  TPDeviceErrorType? deviceError;
  bool get isError => deviceError != null;
  bool isOn;

  bool checkClusterIdExisted(TPDeviceClusterIDType clusterId) {
    final clusterIds = metadata["clusters"] as Map? ?? {};
    return clusterIds.keys.firstWhereOrNull(
            (element) => element == clusterId.value.toString()) !=
        null;
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
    };

    if (deviceError != null) {
      json.update(
        'deviceError',
        (value) => deviceError!.value,
        ifAbsent: () => deviceError!.value,
      );
    }

    return json;
  }

  Future<bool> subscribeDevice() {
    throw UnimplementedError('subscribeDevice() method has not implement');
  }

  TPDevice copyWith({
    String? deviceId,
    String? deviceName,
    TPDeviceType? deviceType,
    DateTime? createdDate,
    bool? isOn,
    Map<String, dynamic>? metadata,
  }) {
    return TPDevice(
      deviceId ?? this.deviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      endpoint,
      subDevices,
      isOn ?? this.isOn,
      metadata ?? this.metadata,
    )..deviceError = deviceError;
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
