import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

abstract class TPLightbulbDevicePlatform extends PlatformInterface {
  TPLightbulbDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TPLightbulbDevicePlatform _instance = MethodChannelTpLightbulbDevice();

  static TPLightbulbDevicePlatform get instance => _instance;

  static set instance(TPLightbulbDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<TPDeviceControlResponse> turnON(TPDevice device) {
    throw UnimplementedError('getDiscoverDevice() has not been implemented.');
  }

  Future<TPDeviceControlResponse> turnOFF(TPDevice device) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> subscriptionWithDeviceId(TPDevice device) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }
}
