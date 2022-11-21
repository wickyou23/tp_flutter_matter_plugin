import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_commission_method_channel.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';

abstract class TpMatterCommissionPlatform extends PlatformInterface {
  TpMatterCommissionPlatform() : super(token: _token);

  static final Object _token = Object();

  static TpMatterCommissionPlatform _instance =
      MethodChannelTpMatterCommission();

  static TpMatterCommissionPlatform get instance => _instance;

  static set instance(TpMatterCommissionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> startOnNetworkCommissionByQRCode(
      String address,
      String qrCode,
      Function(TPDevice?, CommisstionError?)? commissionComlepted) {
    throw UnimplementedError('startCommission() has not been implemented.');
  }

  Future<bool> startThreadCommission(String qrCode,
      Function(TPDevice?, CommisstionError?)? commissionComlepted) {
    throw UnimplementedError(
        'startThreadCommission() has not been implemented.');
  }

  Future<bool> startCommissionByQRCode(String qrCode,
      Function(TPDevice?, CommisstionError?)? commissionComlepted) {
    throw UnimplementedError('startCommission() has not been implemented.');
  }
}
