import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class TPMatterQRCodePairing extends StatefulWidget {
  const TPMatterQRCodePairing({super.key});

  @override
  State<TPMatterQRCodePairing> createState() => _TPMatterQRCodePairingState();
}

class _TPMatterQRCodePairingState extends State<TPMatterQRCodePairing> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  Barcode? result;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('QRCode Pairing'),
        backgroundColor: Colors.blueAccent,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (result != null) {
        return;
      }

      result = scanData;
      controller.resumeCamera();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(scanData.code);
      });
    });
  }
}
