import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tp_flutter_matter_package_platform_interface.dart';

/// An implementation of [TpFlutterMatterPackagePlatform] that uses method channels.
class MethodChannelTpFlutterMatterPackage
    extends TpFlutterMatterPackagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tp_flutter_matter_package');
}
