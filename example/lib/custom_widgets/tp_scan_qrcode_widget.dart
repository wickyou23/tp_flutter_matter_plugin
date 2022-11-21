import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_commission_device_manager.dart';

class TPScanQRCode extends StatefulWidget {
  const TPScanQRCode({super.key});

  @override
  State<TPScanQRCode> createState() => _TPScanQRCodeState();
}

class _TPScanQRCodeState extends State<TPScanQRCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? _controller;
  Barcode? result;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: 8),
        Text(
          'Scan code or hold iPhone near the accessory.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: Colors.black,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 50,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: 'Scan a Setup Code\n',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.black,
                            ),
                        children: [
                          TextSpan(
                            text:
                                'Look for a QR code on the accessory, packaging, or instructions and position it in the camera frame above.',
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.nfc_sharp,
                    size: 50,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: 'Hold iPhone Near Accessory\n',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.black,
                            ),
                        children: [
                          TextSpan(
                            text:
                                'You can also hold iPhone near this symbol if it appears on the accessory.',
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    _controller!.scannedDataStream.listen((scanData) {
      if (result != null) {
        return;
      }

      result = scanData;
      controller.pauseCamera();

      Future.delayed(const Duration(milliseconds: 500), () async {
        TPCommissionDeviceManager.shared
            .changeToConfirmationState(result!.code!);
      });
    });
  }
}
