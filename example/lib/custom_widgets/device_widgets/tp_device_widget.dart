import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/device_widgets/tp_lighbulb_widget.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/device_widgets/tp_lightbulb_dimmer_widget.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/device_widgets/tp_thermostat_widget.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';

class TPDeviceWidget extends StatefulWidget {
  const TPDeviceWidget({super.key, required this.device});

  final ValueNotifier<TPDevice> device;

  @override
  State<TPDeviceWidget> createState() => _TPDeviceWidgetState();
}

class _TPDeviceWidgetState extends State<TPDeviceWidget> {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300]!.withAlpha((0.5 * 255).toInt()),
      ),
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              children: _buildDeviceDetailsForAllEndpoint(),
            ),
          ),
          if (widget.device.value.subDevices.isNotEmpty)
            SizedBox(
              height: 50,
              child: SmoothPageIndicator(
                controller: pageController,
                count: widget.device.value.subDevices.length + 1,
                effect: const ColorTransitionEffect(
                  dotColor: Colors.white,
                  activeDotColor: Colors.orangeAccent,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            )
        ],
      ),
    );
  }

  List<Widget> _buildDeviceDetailsForAllEndpoint() {
    final widgets = [_getDeviceDetailsWidget(widget.device)];
    for (var subDevice in widget.device.value.subDevices.values) {
      final subDeviceValue =
          TPDeviceManager().getSubDeviceValue(subDevice.subDeviceId ?? '');
      if (subDeviceValue != null) {
        widgets.add(
          _getDeviceDetailsWidget(subDeviceValue),
        );
      }
    }

    return widgets;
  }

  Widget _getDeviceDetailsWidget(ValueNotifier<TPDevice> deviceDetail) {
    final deviceId =
        deviceDetail.value.subDeviceId ?? deviceDetail.value.deviceId;
    switch (widget.device.value.deviceType) {
      case TPDeviceType.kLightbulbDimmer:
        return TPLightbulbDimmerWidget(
            key: ValueKey(deviceId), device: deviceDetail);
      case TPDeviceType.kLightbulb:
        return TPLightBulbWidget(key: ValueKey(deviceId), device: deviceDetail);
      case TPDeviceType.kThermostat:
        return TPThermostatWidget(
            key: ValueKey(deviceId), device: deviceDetail);
      default:
        return Container();
    }
  }
}
