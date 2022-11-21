import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/tp_commission_loading_widget.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/tp_confirmation_comission_widget.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/tp_scan_qrcode_widget.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_commission_device_manager.dart';

class TPParingDevice extends StatefulWidget {
  const TPParingDevice({super.key});

  @override
  State<TPParingDevice> createState() => _TPParingDeviceState();
}

class _TPParingDeviceState extends State<TPParingDevice> {
  late StreamSubscription<CommissionState> _subCommissionStream;
  final StreamController<CommissionState> _innerCommissionStream =
      StreamController<CommissionState>();

  @override
  void initState() {
    _subCommissionStream =
        TPCommissionDeviceManager.shared.state.stream.listen((event) {
      _innerCommissionStream.add(event);
    });

    super.initState();
  }

  @override
  void dispose() {
    _subCommissionStream.cancel();
    _innerCommissionStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          child: StreamBuilder(
            initialData: ScanQRCodeCommissionState(),
            stream: _innerCommissionStream.stream,
            builder: (_, snapshot) {
              final snapshotData = snapshot.data;
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshotData is PreparingCommissionState) {
                return const TPCommissionLoading(
                  key: ValueKey('PreparingCommissionState'),
                );
              }

              if (snapshotData is ConfirmationCommissionState) {
                return TPConfirmationComission(qrCode: snapshotData.qrCode);
              } else if (snapshotData is PreparingCommissionState) {
                _subCommissionStream.cancel();
                _innerCommissionStream.close();
                return const TPCommissionLoading(
                    key: ValueKey('PreparingCommissionState'));
              }

              return const TPScanQRCode();
            },
          ),
        ),
      ),
    );
  }
}
