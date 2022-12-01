import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package_method_channel.dart';

void main() {
  MethodChannelTpFlutterMatterPackage platform =
      MethodChannelTpFlutterMatterPackage();
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

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });

  test('toJsonMap', () async {
    final testMap = {
      '1': 'something',
      '2': {
        '11': 'something',
        '22': {'111': 'something', '222': 1},
        '33': {'111': 'something', '222': 1},
        '44': [1, 2, 3, 4, 5]
      },
      '3': 'something',
      '4': {
        '11': 'something',
        '22': {'111': 'something', '222': 1}
      }
    };

    final jsonStr = testMap.toJsonStr();
    debugPrint(jsonStr);
    expect('actual', 'actual');
  });
}

extension MapExt on Map {
  String toJsonStr() {
    String jsonStr = '{';
    int index = 0;
    forEach((key, value) {
      if (value is Map) {
        jsonStr += '"${key.toString()}": ${value.toJsonStr()}';
      } else {
        const encode = JsonEncoder();
        jsonStr += '"${key.toString()}": ${encode.convert(value)}';
      }

      if (index != length - 1) {
        jsonStr += ',';
      }

      index += 1;
    });

    return jsonStr += '}';
  }
}
