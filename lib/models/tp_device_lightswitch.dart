import 'package:tp_flutter_matter_package/channels/devices/tp_lightswitch_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

class TPLightSwitch extends TPDevice {
  TPLightSwitch(
    super.deviceId,
    super.subDeviceId,
    super.deviceName,
    super.deviceType,
    super.createdDate,
    super.endpoint,
    super.subDevices,
    super.isOn,
    super.metadata, {
    super.bindingDevices = const [],
  });

  TPLightSwitch.fromJson(super.json) : super.fromJson();

  @override
  Future<bool> subscribeDevice() async {
    return await TPLightSwitchDevicePlatform.instance
        .subscriptionWithDeviceId(this);
  }

  @override
  TPLightSwitch copyWith({
    String? deviceName,
    TPDeviceType? deviceType,
    DateTime? createdDate,
    bool? isOn,
    Map<String, dynamic>? metadata,
    bool? sensorDetected,
    List<TPBindingDevice>? bindingDevices,
  }) {
    return TPLightSwitch(
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
