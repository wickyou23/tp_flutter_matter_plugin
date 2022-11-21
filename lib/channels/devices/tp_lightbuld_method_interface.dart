import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_method_channel.dart';

typedef TpLightbuldControlCompleted<T> = void Function(LightbuldError?);

class LightbuldError extends Error {
  final String errorMessage;

  LightbuldError(this.errorMessage);
}

abstract class TpLightbuldDevicePlatform extends PlatformInterface {
  TpLightbuldDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TpLightbuldDevicePlatform _instance = MethodChannelTpLightbuldDevice();

  static TpLightbuldDevicePlatform get instance => _instance;

  static set instance(TpLightbuldDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> turnON(String deviceId, TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDiscoverDevice() has not been implemented.');
  }

  Future<bool> turnOFF(String deviceId, TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> subscriptionWithDeviceId(String deviceId) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }
}
