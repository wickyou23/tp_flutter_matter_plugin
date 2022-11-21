import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_commission_method_interface.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

const tpCommissionSuccessKey = 'CommissionSuccessKey';
const tpCommissionDeviceAttestationFailedKey =
    'CommissionDeviceAttestationFailedKey';
const tpCommissionErrorKey = 'CommissionErrorKey';
const tpCompletetedCommissionKey = "CompletetedCommissionKey";

const numChannelBytes = 3;
const numPanIdBytes = 2;
const numXPanIdBytes = 8;
const numMasterKeyBytes = 16;
const typeChannel = 0;
const typePanId = 1;
const typeXPanId = 2;
const typeMasterKey = 5;

enum CommissionErrorType { commisstionError, commissionAttestationError }

class CommisstionError extends Error {
  final CommissionErrorType errorType;
  final String errorMessage;

  CommisstionError(this.errorType, this.errorMessage);
}

class MethodChannelTpMatterCommission extends TpMatterCommissionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(tpCommissionChannelDomain);
  final eventChannel = const EventChannel(tpCommissionEventChannelDomain);

  StreamSubscription<dynamic>? _commissionSubscription;
  void Function(TPDevice?, CommisstionError?)? _commissionComlepted;

  @override
  Future<bool> startOnNetworkCommissionByQRCode(String address, String qrCode,
      Function(TPDevice? p1, CommisstionError? p2)? commissionComlepted) async {
    _commissionSubscription =
        eventChannel.receiveBroadcastStream().listen(_onComissionEvent);
    _commissionComlepted = commissionComlepted;
    final result = await methodChannel.invokeMethod<bool>(
        'startCommissionByQRCode', {'address': address, 'qrCode': qrCode});

    return result ?? false;
  }

  @override
  Future<bool> startCommissionByQRCode(String qrCode,
      Function(TPDevice? p1, CommisstionError? p2)? commissionComlepted) async {
    _commissionSubscription =
        eventChannel.receiveBroadcastStream().listen(_onComissionEvent);
    _commissionComlepted = commissionComlepted;
    final result = await methodChannel
        .invokeMethod<bool>('startCommissionByQRCode', {'qrCode': qrCode});

    return result ?? false;
  }

  @override
  Future<bool> startThreadCommission(String qrCode,
      Function(TPDevice? p1, CommisstionError? p2)? commissionComlepted) async {
    _commissionSubscription =
        eventChannel.receiveBroadcastStream().listen(_onComissionEvent);
    _commissionComlepted = commissionComlepted;

    debugPrint(_nxpThreadDataSet());
    final result = await methodChannel.invokeMethod<bool>(
        'startThreadCommission',
        {'dataset': _nxpThreadDataSet(), 'qrCode': qrCode});

    return result ?? false;
  }

  String _nxpThreadDataSet() {
    const channel = 15;
    const panId = 4660;
    const xPanId = [0x11, 0x11, 0x11, 0x11, 0x22, 0x22, 0x22, 0x22];
    const masterkey = [
      0x00,
      0x11,
      0x22,
      0x33,
      0x44,
      0x55,
      0x66,
      0x77,
      0x88,
      0x99,
      0xAA,
      0xBB,
      0xCC,
      0xDD,
      0xEE,
      0xFF
    ];

    // Channel
    final List<int> dataSet = [];
    final channelData = [
      typeChannel & 0xFF,
      numChannelBytes & 0xFF,
      0x00,
      ((channel >> 8) & 0xFF),
      channel & 0xFF
    ];
    dataSet.addAll(channelData);

    // PAN ID
    final panIDData = {
      typePanId & 0xFF,
      numPanIdBytes & 0xFF,
      ((panId >> 8) & 0xFF),
      (panId & 0xFF),
    };
    dataSet.addAll(panIDData);

    // Extended PAN ID
    const xPanIDData = [
      typeXPanId & 0xFF,
      numXPanIdBytes & 0xFF,
      ...xPanId,
    ];
    dataSet.addAll(xPanIDData);

    // Network Master Key
    const masterKeyData = [
      typeMasterKey & 0xFF,
      numMasterKeyBytes & 0xFF,
      ...masterkey,
    ];
    dataSet.addAll(masterKeyData);

    return dataSet.fold(
      '',
      (previousValue, element) =>
          previousValue + element.toRadixString(16).padLeft(2, '0'),
    );
  }
}

extension MethodChannelTpMatterCommissionEvent
    on MethodChannelTpMatterCommission {
  void _onComissionEvent(dynamic event) {
    if (event is Map) {
      if (event.containsKey(tpCommissionSuccessKey)) {
        _commissionComlepted?.call(null, null);
      } else if (event.containsKey(tpCommissionErrorKey)) {
        String errorMessage = '';
        Map errorMap = event[tpCommissionErrorKey] as Map;
        errorMessage = (errorMap['errorMessage'] as String?) ?? '';
        _commissionComlepted?.call(
            null,
            CommisstionError(
              CommissionErrorType.commisstionError,
              errorMessage,
            ));
      } else if (event.containsKey(tpCommissionDeviceAttestationFailedKey)) {
        String errorMessage = '';
        Map errorMap = event[tpCommissionDeviceAttestationFailedKey] as Map;
        errorMessage = (errorMap['errorMessage'] as String?) ?? '';
        _commissionComlepted?.call(
            null,
            CommisstionError(
              CommissionErrorType.commissionAttestationError,
              errorMessage,
            ));
      } else if (event.containsKey(tpCompletetedCommissionKey)) {
        final result = event[tpCompletetedCommissionKey] as Map;
        final data = result['data'] as Map;
        _commissionComlepted?.call(TPDevice.getDeviceByType(data), null);
      } else {
        _commissionComlepted?.call(
            null,
            CommisstionError(
              CommissionErrorType.commisstionError,
              'Unknown Error',
            ));
      }
    }

    _commissionSubscription?.cancel();
  }
}
