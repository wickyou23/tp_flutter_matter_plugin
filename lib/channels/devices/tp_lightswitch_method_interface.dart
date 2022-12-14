import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightswitch_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

abstract class TPLightSwitchDevicePlatform extends PlatformInterface {
  TPLightSwitchDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TPLightSwitchDevicePlatform _instance =
      MethodChannelTpLightSwitchDevice();

  static TPLightSwitchDevicePlatform get instance => _instance;

  static set instance(TPLightSwitchDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> subscriptionWithDeviceId(TPDevice device) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }
}
