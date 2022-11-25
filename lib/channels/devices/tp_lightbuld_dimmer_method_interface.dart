import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbuld_dimmer_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

typedef TpLightbuldControlCompleted<T> = void Function(LightbuldError?);

class LightbuldError extends Error {
  final String errorMessage;

  LightbuldError(this.errorMessage);
}

abstract class TpLightbuldDimmerDevicePlatform extends PlatformInterface {
  TpLightbuldDimmerDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TpLightbuldDimmerDevicePlatform _instance =
      MethodChannelTpLightbuldDimmerDevice();

  static TpLightbuldDimmerDevicePlatform get instance => _instance;

  static set instance(TpLightbuldDimmerDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> turnON(
      TPDevice device, TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDiscoverDevice() has not been implemented.');
  }

  Future<bool> turnOFF(
      TPDevice device, TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> controlLevel(TPDevice device, int level,
      TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> subscriptionWithDeviceId(TPDevice device) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> controlTemperatureColorWithDevice(TPDevice device,
      int temperatureColor, TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> controlHueAndSaturationColorWithDevice(TPDevice device, int hue,
      int saturation, TpLightbuldControlCompleted controlCompleted) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }
}
