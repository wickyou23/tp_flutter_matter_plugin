import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tp_flutter_matter_package_method_channel.dart';

abstract class TpFlutterMatterPackagePlatform extends PlatformInterface {
  /// Constructs a TpFlutterMatterPackagePlatform.
  TpFlutterMatterPackagePlatform() : super(token: _token);

  static final Object _token = Object();

  static TpFlutterMatterPackagePlatform _instance = MethodChannelTpFlutterMatterPackage();

  /// The default instance of [TpFlutterMatterPackagePlatform] to use.
  ///
  /// Defaults to [MethodChannelTpFlutterMatterPackage].
  static TpFlutterMatterPackagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TpFlutterMatterPackagePlatform] when
  /// they register themselves.
  static set instance(TpFlutterMatterPackagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}