import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

class TPLightbulbDimmer extends TPDevice {
  TPLightbulbDimmer(
    super.deviceId,
    super.deviceName,
    super.deviceType,
    super.createdDate,
    super.isOn,
    this.dim,
  );

  TPLightbulbDimmer.fromJson(Map json)
      : dim = json['dim'] as int? ?? 50,
        super.fromJson(json);

  int dim;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({'dim': dim});
  }

  Future<bool> turnON(TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDevicePlatform.instance.turnON(deviceId, (p0) {
      if (p0 == null) {
        isOn = true;
      }

      onCompleted(p0);
    });
  }

  Future<bool> turnOFF(TpLightbuldControlCompleted onCompleted) async {
    return await TpLightbuldDevicePlatform.instance.turnOFF(deviceId, (p0) {
      if (p0 == null) {
        isOn = false;
      }

      onCompleted(p0);
    });
  }

  Future<bool> toggle(TpLightbuldControlCompleted onCompleted) async {
    if (isOn) {
      return turnOFF(onCompleted);
    } else {
      return turnON(onCompleted);
    }
  }

  @override
  TPLightbulbDimmer copyWith(
      {String? deviceId,
      String? deviceName,
      TPDeviceType? deviceType,
      DateTime? createdDate,
      bool? isOn,
      int? dim}) {
    return TPLightbulbDimmer(
      deviceId ?? this.deviceId,
      deviceName ?? this.deviceName,
      deviceType ?? this.deviceType,
      createdDate ?? this.createdDate,
      isOn ?? this.isOn,
      dim ?? this.dim,
    );
  }

  @override
  Future<bool> subscribeDevice() async {
    return await TpLightbuldDevicePlatform.instance
        .subscriptionWithDeviceId(deviceId);
  }
}
