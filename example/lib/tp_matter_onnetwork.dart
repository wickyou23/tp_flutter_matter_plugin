import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/models/tp_discover_device.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';
import 'package:tp_flutter_matter_package_example/tp_matter_qrcode_pairing.dart';

class TPMatterOnNetworkPairing extends StatefulWidget {
  const TPMatterOnNetworkPairing({super.key});

  @override
  State<TPMatterOnNetworkPairing> createState() =>
      _TPMatterOnNetworkPairingState();
}

class _TPMatterOnNetworkPairingState extends State<TPMatterOnNetworkPairing> {
  final _tpFlutterMatterPlugin = TpFlutterMatterPlugin();

  List<TPDiscoverDevice> devices = [];
  final isShowLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('On Network Paring'),
        backgroundColor: Colors.blueAccent,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover Devices:',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            Expanded(
                child: ValueListenableBuilder(
              valueListenable: isShowLoading,
              builder: (_, value, child) {
                if (value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (devices.isNotEmpty) {
                    return ListView.builder(
                      itemBuilder: (_, index) {
                        final item = devices[index];
                        return GestureDetector(
                          onTap: () async {
                            final qrCode = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) {
                                  return const TPMatterQRCodePairing();
                                },
                                settings: const RouteSettings(
                                    name: '/TPMatterQRCodePairing'),
                              ),
                            );

                            if (qrCode is String) {
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              await _startCommissionByQRCode(item, qrCode);
                            }
                          },
                          child: Card(
                            key: ValueKey("$index"),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.deviceName.isNotEmpty
                                        ? item.deviceName
                                        : "Unknown Device",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.ipAddressList.firstOrNull ??
                                        "Unknown IPv4",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: devices.length,
                    );
                  } else {
                    return Center(
                      child: CupertinoButton.filled(
                        child: const Text('Discover Devices'),
                        onPressed: () async {
                          await getDiscoverDevice();
                        },
                      ),
                    );
                  }
                }
              },
            ))
          ],
        ),
      ),
    );
  }

  Future<void> getDiscoverDevice() async {
    isShowLoading.value = true;
    devices = await _tpFlutterMatterPlugin.getDiscoverDevice();
    isShowLoading.value = false;
  }

  // Future<void> _startCommission(TPDiscoverDevice device) async {
  //   isShowLoading.value = true;
  //   await _tpFlutterMatterPlugin.startCommission(
  //     device.ipAddressList.first!,
  //     device.discriminator.toString(),
  //     '65656566',
  //     (device, error) {
  //       if (error != null) {
  //         isShowLoading.value = false;
  //         ScaffoldMessenger.of(context)
  //           ..hideCurrentSnackBar()
  //           ..showSnackBar(
  //             SnackBar(
  //               content: Text('[Error]: ${error.errorMessage}'),
  //             ),
  //           );
  //       } else {
  //         Navigator.of(context).pop();
  //       }
  //     },
  //   );
  // }

  Future<void> _startCommissionByQRCode(
      TPDiscoverDevice device, String qrCode) async {
    isShowLoading.value = true;
    // await _tpFlutterMatterPlugin.startCommissionByQRCode(
    //   device.ipAddressList.first!,
    //   device.discriminator.toString(),
    //   qrCode,
    //   (device, error) async {
    //     if (error != null) {
    //       isShowLoading.value = false;
    //       ScaffoldMessenger.of(context)
    //         ..hideCurrentSnackBar()
    //         ..showSnackBar(
    //           SnackBar(
    //             content: Text('[Error]: ${error.errorMessage}'),
    //           ),
    //         );
    //     } else {
    //       if (device != null) {
    //         await TPDeviceManager().addAndSaveDevice(device);
    //       }

    //       if (!mounted) {
    //         return;
    //       }

    //       Navigator.of(context).pop();
    //     }
    //   },
    // );
  }
}
