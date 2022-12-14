import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/device_widgets/tp_lightbulb_dimmer_widget.dart';

class TPDeviceWidget extends StatelessWidget {
  const TPDeviceWidget({super.key, required this.device});

  final ValueNotifier<TPDevice> device;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300]!.withAlpha((0.5 * 255).toInt()),
      ),
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height / 2),
      child: _getDeviceDetailsWidget(),
    );
  }

  Widget _getDeviceDetailsWidget() {
    switch (device.value.deviceType) {
      case TPDeviceType.kLightbulbDimmer:
        return TPLightbulbDimmerWidget(device: device);
      default:
        return Container();
    }
  }
}
