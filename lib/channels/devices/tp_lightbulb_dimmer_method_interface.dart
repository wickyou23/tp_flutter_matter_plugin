import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_lightbulb_dimmer_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

abstract class TpLightbulbDimmerDevicePlatform extends PlatformInterface {
  TpLightbulbDimmerDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TpLightbulbDimmerDevicePlatform _instance =
      MethodChannelTpLightbulbDimmerDevice();

  static TpLightbulbDimmerDevicePlatform get instance => _instance;

  static set instance(TpLightbulbDimmerDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<TPDeviceControlResponse> turnON(TPDevice device) {
    throw UnimplementedError('getDiscoverDevice() has not been implemented.');
  }

  Future<TPDeviceControlResponse> turnOFF(TPDevice device) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlLevel(TPDevice device, int level) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<bool> subscriptionWithDeviceId(TPDevice device) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlTemperatureColorWithDevice(
      TPDevice device, int temperatureColor) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlHueAndSaturationColorWithDevice(
      TPDevice device, int hue, int saturation) {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }
}
