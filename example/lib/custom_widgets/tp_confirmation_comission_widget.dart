import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_commission_device_manager.dart';

class TPConfirmationComission extends StatefulWidget {
  const TPConfirmationComission({super.key, required this.qrCode});

  final String qrCode;

  @override
  State<TPConfirmationComission> createState() =>
      _TPConfirmationComissionState();
}

class _TPConfirmationComissionState extends State<TPConfirmationComission> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close_rounded,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            'Add Accessory',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'resources/images/homekit.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
          CupertinoButton.filled(
            child: const Text('Add to Home'),
            onPressed: () {
              TPCommissionDeviceManager.shared
                  .startCommisionByQRCode(widget.qrCode);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
