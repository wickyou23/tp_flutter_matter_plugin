import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';

class TPLightBulbWidget extends StatefulWidget {
  const TPLightBulbWidget({super.key, required this.device});

  final ValueNotifier<TPDevice> device;

  @override
  State<TPLightBulbWidget> createState() => _TPLightBulbWidgetState();
}

class _TPLightBulbWidgetState extends State<TPLightBulbWidget> {
  TPLightbulb get lightbulb {
    return widget.device.value as TPLightbulb;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.device,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 60,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lightbulb.getDeviceName(),
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Visibility(
                    visible: lightbulb.subDevices.values.isNotEmpty ||
                        !lightbulb.isMainDevice,
                    child: Text(
                      '(Endpoint ${lightbulb.endpoint})',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoButton(
                onPressed: () async {
                  final response = await lightbulb.toggle();
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
                    if (!lightbulb.isMainDevice) {
                      widget.device.value = lightbulb;
                    }

                    await TPDeviceManager().updateDevice(lightbulb);
                  }
                },
                padding: EdgeInsets.zero,
                child: Image(
                  image: lightbulb.getControllerIcon(),
                  width: 150,
                  height: 150,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
