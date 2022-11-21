import 'dart:async';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/TPCupertinoSliverNavigationBar.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/tp_paring_device_widget.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_device_manager.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_storage_data.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_commission_device_manager.dart';

void main() {
  runZonedGuarded(() async {
    final _ = WidgetsFlutterBinding.ensureInitialized();
    await TPLocalStorageData().configuration();

    runApp(
      const CupertinoSnackApp(
        home: MyApp(),
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          textTheme: CupertinoTextThemeData(
            navLargeTitleTextStyle: TextStyle(
              inherit: false,
              fontFamily: '.SF Pro Display',
              fontSize: 34.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.41,
              color: Colors.white,
            ),
            navTitleTextStyle: TextStyle(
              inherit: false,
              fontFamily: '.SF Pro Text',
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }, (Object error, StackTrace stackTrace) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ValueNotifier<TPDevice>> get _devices => TPDeviceManager().devices;

  final _isShowLoading = ValueNotifier<bool>(false);
  final _tpFlutterMatterPlugin = TpFlutterMatterPlugin();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _getDeviceList();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'resources/images/default_bg_image.jpg',
            fit: BoxFit.fill,
          ),
          CustomScrollView(
            slivers: [
              const TPCupertinoSliverNavigationBar(
                middleBackgroundColor: Colors.black12,
                backgroundColor: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.transparent,
                    width: 0.0, // 0.0 means one physical pixel
                  ),
                ),
                largeTitle: Text('My Home'),
              ),
              ValueListenableBuilder(
                valueListenable: _isShowLoading,
                builder: (context, value, child) {
                  if (value) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) {
                            if (index == _devices.length) {
                              return _addAccessoryCellWidget();
                            }

                            final item = _devices[index];
                            return _deviceCellWidget(item);
                          },
                          childCount: _devices.length + 1,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2 / 1.8,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> showDeviceActions(TPDevice device) {
    return showCupertinoModalPopup(
      context: context,
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(10),
      //     topRight: Radius.circular(10),
      //   ),
      // ),
      builder: (context) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _unpairDevice(device.deviceId);
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Unpair Device',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _deviceCellWidget(ValueNotifier<TPDevice> deviceValue) {
    return ValueListenableBuilder(
      key: ValueKey(deviceValue.value.deviceId),
      valueListenable: deviceValue,
      builder: (_, device, __) {
        return GestureDetector(
          onTap: () {
            showDeviceActions(device);
          },
          onDoubleTap: () {
            if (device is TPLightbulbDimmer) {
              device.toggle((p0) async {
                if (p0 != null) {
                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('[Error]: ${p0.errorMessage}'),
                      ),
                    );
                } else {
                  await TPDeviceManager().updateDevice(device);
                }
              });
            }
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              color: device.isOn
                  ? Colors.orange[100]!.withAlpha((0.6 * 255).toInt())
                  : Colors.white24,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: device.getIcon(),
                    width: 50,
                    height: 50,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Device ${device.deviceId}',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.getStatusText(),
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _addAccessoryCellWidget() {
    return GestureDetector(
      key: const ValueKey('_addAccessoryCellWidget'),
      onTap: () {
        _showQRCodeScanner();
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Container(
          color: Colors.white24,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: 0.5,
                  child: Icon(
                    Icons.add_circle,
                    size: 50,
                    color: Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Add accessory',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showQRCodeScanner() {
    return showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const TPParingDevice();
      },
    ).then((value) {
      _getDeviceList();
    });
  }

  Future<void> _getDeviceList() async {
    _isShowLoading.value = true;
    final nativeDevices = await _tpFlutterMatterPlugin.getDeviceList();
    await TPDeviceManager().getAndSyncDevice(nativeDevices);
    _isShowLoading.value = false;
  }

  Future<void> _unpairDevice(String deviceId) async {
    _isShowLoading.value = true;
    final success = await _tpFlutterMatterPlugin.unpairDevice(deviceId);

    if (!success && mounted) {
      _isShowLoading.value = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('[Error]: Unpair failed'),
          ),
        );
    } else {
      await TPDeviceManager().removeDevice(deviceId);
      _isShowLoading.value = false;
    }
  }
}
