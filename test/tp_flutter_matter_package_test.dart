import 'package:flutter_test/flutter_test.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package_platform_interface.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTpFlutterMatterPackagePlatform
    with MockPlatformInterfaceMixin
    implements TpFlutterMatterPackagePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TpFlutterMatterPackagePlatform initialPlatform = TpFlutterMatterPackagePlatform.instance;

  test('$MethodChannelTpFlutterMatterPackage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTpFlutterMatterPackage>());
  });

  test('getPlatformVersion', () async {
    TpFlutterMatterPlugin tpFlutterMatterPackagePlugin = TpFlutterMatterPlugin();
    MockTpFlutterMatterPackagePlatform fakePlatform = MockTpFlutterMatterPackagePlatform();
    TpFlutterMatterPackagePlatform.instance = fakePlatform;

    expect(await tpFlutterMatterPackagePlugin.getPlatformVersion(), '42');
  });
}
