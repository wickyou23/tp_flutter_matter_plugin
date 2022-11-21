import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package_method_channel.dart';

void main() {
  MethodChannelTpFlutterMatterPackage platform = MethodChannelTpFlutterMatterPackage();
  const MethodChannel channel = MethodChannel('tp_flutter_matter_package');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
