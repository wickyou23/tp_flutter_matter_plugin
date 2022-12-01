import 'dart:async';
import 'dart:ui';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/TPCupertinoSliverNavigationBar.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/device_widgets/tp_device_widget.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/tp_paring_device_widget.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_device_manager.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_storage_data.dart';
import 'package:tp_flutter_matter_package_example/tp_device_settings.dart';

void main() {
  runZonedGuarded(() async {
    final _ = WidgetsFlutterBinding.ensureInitialized();
    await TPLocalStorageData().configuration();

    runApp(
      const CupertinoSnackApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
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
              fontSize: 18.0,
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
              TPCupertinoSliverNavigationBar(
                middleBackgroundColor: Colors.black12,
                backgroundColor: Colors.transparent,
                padding: const EdgeInsetsDirectional.only(end: 0),
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.transparent,
                    width: 0.0, // 0.0 means one physical pixel
                  ),
                ),
                largeTitle: const Text('My Home'),
                trailing: CupertinoButton(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    right: 8,
                  ),
                  child: const Icon(
                    CupertinoIcons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const TPDeviceSettings(),
                      ),
                    );
                  },
                ),
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

  Future<dynamic> _showDeviceActions(TPDevice device) {
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

  Widget _deviceCellWidget(ValueNotifier<TPDevice> deviceNotifier) {
    return ValueListenableBuilder(
      key: ValueKey(deviceNotifier.value.deviceId),
      valueListenable: deviceNotifier,
      builder: (_, device, __) {
        return GestureDetector(
          onTap: () {
            _showDeviceDetails(deviceNotifier);
          },
          onLongPress: () {
            _showDeviceActions(device);
          },
          onDoubleTap: () {
            _handleDoubleTap(deviceNotifier);
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              color: device.isOn
                  ? Colors.orange[100]!.withAlpha((0.6 * 255).toInt())
                  : Colors.white24,
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
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
                            device.getDeviceName(),
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
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  _buildSensorOrErrorWidget(device),
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

  Widget _buildSensorOrErrorWidget(TPDevice device) {
    Widget sensorWidget(bool sensorDetected, AssetImage iconImage) {
      return Positioned(
        right: 0,
        child: Opacity(
          opacity: sensorDetected ? 1 : 0.5,
          child: Image(
            image: iconImage,
            width: 20,
            height: 20,
          ),
        ),
      );
    }

    if (device.isError) {
      return const Positioned(
        right: 0,
        child: Icon(
          Icons.error_rounded,
          color: CupertinoColors.systemRed,
          size: 20,
        ),
      );
    }

    if (device is TPLightbulbDimmer) {
      if (!device.isSupportedSensorDevice) {
        return Container();
      }

      return sensorWidget(
        device.sensorDetected,
        device.getSensorIcon(),
      );
    } else if (device is TPLightbulb) {
      if (!device.isSupportedSensorDevice) {
        return Container();
      }

      return sensorWidget(
        device.sensorDetected,
        device.getSensorIcon(),
      );
    } else {
      return Container();
    }
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

  Future<dynamic>? _showDeviceDetails(ValueNotifier<TPDevice> device) {
    final deviceValue = device.value;
    if (deviceValue is TPLightbulbDimmer) {
      if (!deviceValue.isSupportedLevelControl &&
          !deviceValue.isSupportedColorControl) {
        return null;
      }
    } else if (deviceValue is TPLightbulb) {
      return null;
    }

    return showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      builder: (_) {
        return TPDeviceWidget(device: device);
      },
    );
  }

  Future<void> _handleDoubleTap(ValueNotifier<TPDevice> device) async {
    final deviceValue = device.value;
    if (deviceValue is TPLightbulbDimmer) {
      final response = await deviceValue.toggle();
      if (response is TPDeviceControlError) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('[Error]: ${response.errorMessage}'),
            ),
          );
      } else {
        await TPDeviceManager().updateDevice(deviceValue);
      }
    } else if (deviceValue is TPLightbulb) {
      final response = await deviceValue.toggle();
      if (response is TPDeviceControlError) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('[Error]: ${response.errorMessage}'),
            ),
          );
      } else {
        await TPDeviceManager().updateDevice(deviceValue);
      }
    }
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
