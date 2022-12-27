import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_thermostat_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_thermostat.dart';

abstract class TPThermostatDevicePlatform extends PlatformInterface {
  TPThermostatDevicePlatform() : super(token: _token);

  static final Object _token = Object();

  static TPThermostatDevicePlatform _instance =
      MethodChannelTPThermostatDevice();

  static TPThermostatDevicePlatform get instance => _instance;

  static set instance(TPThermostatDevicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> subscriptionWithDeviceId(TPDevice device) async {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlSystemMode(
      TPDevice device, TPThermostatMode mode) async {
    throw UnimplementedError('controlSystemMode() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlMinCool(
      TPDevice device, double min) async {
    throw UnimplementedError('controlMinCool() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlMaxCool(
      TPDevice device, double max) async {
    throw UnimplementedError('controlMaxCool() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlMinHeat(
      TPDevice device, double min) async {
    throw UnimplementedError('controlMinHeat() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlMaxHeat(
      TPDevice device, double max) async {
    throw UnimplementedError('controlMaxHeat() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlOccupiedCooling(
      TPDevice device, double occupiedCooling) async {
    throw UnimplementedError(
        'controlOccupiedCooling() has not been implemented.');
  }

  Future<TPDeviceControlResponse> controlOccupiedHeating(
      TPDevice device, double occupiedHeating) async {
    throw UnimplementedError(
        'controlOccupiedHeating() has not been implemented.');
  }
}
