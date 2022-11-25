import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tp_flutter_matter_package/models/tp_setup_payload.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_device_manager.dart';

enum CommissionStep {
  kScanQRCode,
  kOnNetworkParing,
  kBLE,
  kDiscoverDevice,
  kPairing,
  kDeviceName,
  kCompleted
}

abstract class CommissionState {}

class ScanQRCodeCommissionState extends CommissionState {}

class ConfirmationCommissionState extends CommissionState {
  final String qrCode;

  ConfirmationCommissionState(this.qrCode);
}

class PreparingCommissionState extends CommissionState {}

class DiscoverDeviceCommissionState extends CommissionState {}

class PairingDeviceCommissionState extends CommissionState {}

class CommissionFailedState extends CommissionState {
  final String errorCode;
  final String errorMessage;

  CommissionFailedState(this.errorCode, this.errorMessage);
}

class CommissionSuccessState extends CommissionState {}

class TPCommissionDeviceManager {
  static final shared = TPCommissionDeviceManager._internal();

  final _tpMatterPlugin = TpFlutterMatterPlugin();

  TPCommissionDeviceManager._internal();

  StreamController<CommissionState> state =
      StreamController<CommissionState>.broadcast(sync: true);

  void changeToConfirmationState(String qrCode) {
    state.add(ConfirmationCommissionState(qrCode));
  }

  Future<void> startCommisionByQRCode(String qrCode) async {
    final setupPayload =
        await _tpMatterPlugin.getSetupPayloadFromQRCodeString(qrCode);
    debugPrint(setupPayload.toString());

    if (setupPayload != null) {
      if (setupPayload.discoveryCapabilities
              .contains(TPDiscoveryCapabilities.kDiscoveryCapabilitiesBLE) &&
          !setupPayload.discoveryCapabilities.contains(
              TPDiscoveryCapabilities.kDiscoveryCapabilitiesOnNetwork)) {
        _startThreadCommisionByQRCode(qrCode);
      } else {
        _startDefaultCommisionByQRCode(qrCode);
      }
    } else {
      state.add(
          CommissionFailedState('PAYLOAD_INVALID', 'Setup payload is invalid'));
      return;
    }
  }

  Future<void> _startDefaultCommisionByQRCode(String qrCode) async {
    state.add(PreparingCommissionState());
    await Future.delayed(const Duration(seconds: 1));
    state.add(PairingDeviceCommissionState());
    await _tpMatterPlugin.startCommissionByQRCode(qrCode,
        (device, error) async {
      if (error != null) {
        state.add(CommissionFailedState(
            'COMMISSION_FAILED', '[ERROR]: ${error.errorMessage}'));
      } else {
        if (device != null) {
          await TPDeviceManager().addAndSaveDevice(device);
        }

        state.add(CommissionSuccessState());
      }
    });
  }

  Future<void> _startThreadCommisionByQRCode(String qrCode) async {
    state.add(PreparingCommissionState());
    await Future.delayed(const Duration(seconds: 1));
    state.add(PairingDeviceCommissionState());
    await _tpMatterPlugin.startThreadCommission(qrCode, (device, error) async {
      if (error != null) {
        state.add(CommissionFailedState(
            'COMMISSION_FAILED', '[ERROR]: ${error.errorMessage}'));
      } else {
        if (device != null) {
          await TPDeviceManager().addAndSaveDevice(device);
        }

        state.add(CommissionSuccessState());
      }
    });
  }

  // Future<void> startOnNetworkCommisionByQRCode(String qrCode) async {
  //   final setupPayload =
  //       await _tpMatterPlugin.getSetupPayloadFromQRCodeString(qrCode);
  //   debugPrint(setupPayload.toString());

  //   if (setupPayload != null) {
  //     _playload = setupPayload;
  //     if (setupPayload.discoveryCapabilities
  //         .contains(TPDiscoveryCapabilities.kDiscoveryCapabilitiesOnNetwork)) {
  //       state.add(OnNetworkCommissionState(setupPayload));
  //     }
  //   } else {
  //     state.add(
  //         CommissionFailedState('PAYLOAD_INVALID', 'Setup payload is invalid'));
  //   }
  // }

  // Future<void> commissionOnNetwork() async {
  //   if (_playload == null) {
  //     state.add(
  //         CommissionFailedState('PAYLOAD_INVALID', 'Setup payload is invalid'));
  //     return;
  //   }

  //   state.add(PreparingCommissionState());
  //   await Future.delayed(const Duration(seconds: 1));
  //   state.add(DiscoverDeviceCommissionState());
  //   final discoverDevices = await _tpMatterPlugin.getDiscoverDevice();
  //   final findDevice = discoverDevices.firstWhereOrNull((element) {
  //     return element.discriminator == _playload!.discriminator;
  //   });

  //   if (findDevice != null && findDevice.ipAddressList.isNotEmpty) {
  //     state.add(PairingDeviceCommissionState());
  //     await _tpMatterPlugin.startOnNetworkCommissionByQRCode(
  //         findDevice.ipAddressList.first!, _playload!.setupPasscode,
  //         (device, error) async {
  //       if (error != null) {
  //         state.add(CommissionFailedState(
  //             'COMMISSION_FAILED', '[ERROR]: ${error.errorMessage}'));
  //       } else {
  //         if (device != null) {
  //           await TPDeviceManager().addAndSaveDevice(device);
  //         }

  //         state.add(CommissionSuccessState());
  //         cancelCommission();
  //       }
  //     });
  //   } else {
  //     state.add(CommissionFailedState(
  //         'DISCOVER_DEVICE_INVALID', 'Cannot found device valid'));
  //   }
  // }
}
