import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_device_method_interface.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_helper.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_discover_device.dart';
import 'package:tp_flutter_matter_package/models/tp_setup_payload.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

class MethodChannelTpMatterDevice extends TpMatterDevicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(tpDeviceChannelDomain);

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<TPDiscoverDevice>> getDiscoverDevice() async {
    final result = await methodChannel.invokeListMethod('getDiscoverDevice');
    if (result != null) {
      return result
          .map((e) =>
              TPDiscoverDevice.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return [];
  }

  @override
  Future<List<String>> getDeviceList() async {
    final result = await methodChannel.invokeListMethod('getDeviceList');
    if (result != null) {
      return result.map((e) => e as String).toList();
    }

    return [];
  }

  @override
  Future<bool> unpairDeviceById(String deviceId) async {
    final result = await methodChannel
        .invokeMethod<int>('unpairDeviceById', {'deviceId': deviceId});
    return result == 1 ? true : false;
  }

  @override
  Future<TPSetupPlayload?> getSetupPayloadFromQRCodeString(
      String qrCode) async {
    final result = await methodChannel.invokeMethod<Map>(
        'getSetupPayloadFromQRCodeString', {'qrCode': qrCode});
    if (result != null) {
      return TPSetupPlayload.fromJson(result);
    }

    return null;
  }

  @override
  Future<TPMatterResponse> saveBindingWithDevice(TPDevice device,
      Map<TPDeviceClusterIDType, List<TPDevice>> bindingDevices) async {
    final result =
        await methodChannel.invokeMethod<Map>('saveBindingWithDeviceId', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
      'bindingDevices': _preparedBindingDevicesData(bindingDevices),
    });

    return TPMatterHelper.handleControlResponse(result);
  }

  @override
  Future<TPMatterResponse> readBindingDatasWithDevice(TPDevice device) async {
    final result =
        await methodChannel.invokeMethod<Map>('readBindingDatasWithDeviceId', {
      'deviceId': device.deviceId,
      'endpoint': device.endpoint,
    });

    return TPMatterHelper.handleControlResponse(result);
  }

  void _preparedThreadPlayload() {}

  List<Map<String, dynamic>> _preparedBindingDevicesData(
      Map<TPDeviceClusterIDType, List<TPDevice>> bindingDevices) {
    final List<Map<String, dynamic>> bindingDevicesData = [];
    bindingDevices.forEach((key, value) {
      for (var device in value) {
        bindingDevicesData.add({
          'fabricIndex': 1,
          'node': int.parse(device.deviceId),
          'endpoint': device.endpoint,
          'cluster': key.value,
        });
      }
    });

    return bindingDevicesData;
  }
}

// - (void)retrieveThreadCredentials
// {
//     UIAlertController * alertController =
//     [UIAlertController alertControllerWithTitle:@"Thread configuration"
//                                         message:@"Enter credentials of the Thread network that you want to put your CHIP device on."
//                                  preferredStyle:UIAlertControllerStyleAlert];
//     [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField) {
//         textField.placeholder = @"Channel";
//         textField.text = @"15";
//         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//         textField.borderStyle = UITextBorderStyleRoundedRect;
//     }];
    
//     [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField) {
//         textField.placeholder = @"PAN ID";
//         textField.text = @"1234";
//         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//         textField.borderStyle = UITextBorderStyleRoundedRect;
//     }];
    
//     [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField) {
//         textField.placeholder = @"Extended PAN ID";
//         textField.text = @"11:11:11:11:22:22:22:22";
//         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//         textField.borderStyle = UITextBorderStyleRoundedRect;
//     }];
    
//     [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField) {
//         textField.placeholder = @"Master key";
//         textField.text = @"00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF";
//         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//         textField.borderStyle = UITextBorderStyleRoundedRect;
//     }];
    
//     [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action) {
//     }]];
    
//     __weak typeof(self) weakSelf = self;
//     [alertController
//      addAction:[UIAlertAction actionWithTitle:@"Send"
//                                         style:UIAlertActionStyleDefault
//                                       handler:^(UIAlertAction * action) {
//         typeof(self) strongSelf = weakSelf;
//         if (strongSelf) {
//             NSArray * textfields = alertController.textFields;
//             UITextField * channel = textfields[0];
//             UITextField * panID = textfields[1];
//             UITextField * extendedPanID = textfields[2];
//             UITextField * masterKey = textfields[3];
//             [strongSelf commissionWithChannel:channel.text
//                                         panID:panID.text
//                                 extendedPanID:extendedPanID.text
//                                     masterKey:masterKey.text];
//         }
//     }]];
//     [self presentViewController:alertController animated:YES completion:nil];
// }
