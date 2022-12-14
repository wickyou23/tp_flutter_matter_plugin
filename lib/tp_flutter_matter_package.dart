import 'package:tp_flutter_matter_package/channels/tp_matter_commission_method_channel.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_commission_method_interface.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_device_method_interface.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_helper.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_discover_device.dart';
import 'package:tp_flutter_matter_package/models/tp_setup_payload.dart';

class TpFlutterMatterPlugin {
  Future<String?> getPlatformVersion() {
    return TpMatterDevicePlatform.instance.getPlatformVersion();
  }

  Future<List<TPDiscoverDevice>> getDiscoverDevice() {
    return TpMatterDevicePlatform.instance.getDiscoverDevice();
  }

  Future<bool> startOnNetworkCommissionByQRCode(String address, String qrCode,
      void Function(TPDevice?, CommisstionError?)? commissionComlepted) async {
    return await TpMatterCommissionPlatform.instance
        .startOnNetworkCommissionByQRCode(address, qrCode, commissionComlepted);
  }

  Future<bool> startCommissionByQRCode(String qrCode,
      void Function(TPDevice?, CommisstionError?)? commissionComlepted) async {
    return await TpMatterCommissionPlatform.instance
        .startCommissionByQRCode(qrCode, commissionComlepted);
  }

  Future<bool> startThreadCommission(String qrCode,
      Function(TPDevice?, CommisstionError?)? commissionComlepted) async {
    return await TpMatterCommissionPlatform.instance
        .startThreadCommission(qrCode, commissionComlepted);
  }

  Future<List<String>> getDeviceList() async {
    return await TpMatterDevicePlatform.instance.getDeviceList();
  }

  Future<bool> unpairDevice(String deviceId) async {
    return await TpMatterDevicePlatform.instance.unpairDeviceById(deviceId);
  }

  Future<TPSetupPlayload?> getSetupPayloadFromQRCodeString(
      String qrCode) async {
    return await TpMatterDevicePlatform.instance
        .getSetupPayloadFromQRCodeString(qrCode);
  }

  Future<TPMatterResponse> saveBindingWithDevice(TPDevice device,
      Map<TPDeviceClusterIDType, List<TPDevice>> bindingDevices) async {
    return await TpMatterDevicePlatform.instance
        .saveBindingWithDevice(device, bindingDevices);
  }

  Future<TPMatterResponse> readBindingDatasWithDevice(TPDevice device) async {
    final result = await TpMatterDevicePlatform.instance
        .readBindingDatasWithDevice(device);
    if (result is TPMatterResponseSuccess) {
      final datas = result.data;
      if (datas is List) {
        return TPMatterResponseSuccess<List<TPBindingDevice>>(
          result.deviceId,
          data: datas.map((e) => TPBindingDevice.fromJson(e as Map)).toList(),
        );
      }
    }

    return result;
  }
}
