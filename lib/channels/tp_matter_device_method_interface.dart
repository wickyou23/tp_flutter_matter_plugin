import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_device_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_discover_device.dart';
import 'package:tp_flutter_matter_package/models/tp_setup_payload.dart';

abstract class TpMatterDevicePlatform extends PlatformInterface {
  TpMatterDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TpMatterDevicePlatform _instance = MethodChannelTpMatterDevice();

  static TpMatterDevicePlatform get instance => _instance;

  static set instance(TpMatterDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<TPDiscoverDevice>> getDiscoverDevice() {
    throw UnimplementedError('getDiscoverDevice() has not been implemented.');
  }

  Future<List<String>> getDeviceList() {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> unpairDeviceById(String deviceId) {
    throw UnimplementedError('unpairDeviceById() has not been implemented.');
  }

  Future<TPSetupPlayload?> getSetupPayloadFromQRCodeString(String qrCode) {
    throw UnimplementedError('getSetupPayloadFromQRCodeString() has not been implemented.');
  }
}
