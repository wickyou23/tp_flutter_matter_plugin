import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/TPCupertinoSliverNavigationBarNoLargerTitle.dart';
import 'package:tp_flutter_matter_package_example/datas/tp_device_manager.dart';

class TPDeviceSettingDetails extends StatefulWidget {
  const TPDeviceSettingDetails({super.key, required this.device});

  final ValueNotifier<TPDevice> device;

  @override
  State<TPDeviceSettingDetails> createState() => _TPDeviceSettingDetailsState();
}

class _TPDeviceSettingDetailsState extends State<TPDeviceSettingDetails> {
  final _deviceNameTextFieldController = TextEditingController();
  final _deviceFocusNode = FocusNode();

  @override
  void initState() {
    _deviceNameTextFieldController.text = widget.device.value.deviceName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          ValueListenableBuilder(
            key: const ValueKey('SliverPersistentHeader'),
            valueListenable: widget.device,
            builder: ((_, value, __) {
              return SliverPersistentHeader(
                delegate: TPCupertinoSliverNavigationBarNoLargerTitle(
                  context,
                  title: value.getDeviceName(),
                  previousPageTitle: 'Settings',
                ),
                pinned: true,
                floating: false,
              );
            }),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _generalWidget(),
                  const SizedBox(height: 30),
                  _actionsWidget(),
                  const SizedBox(height: 40),
                  _unpairWidget(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _generalWidget() {
    Widget deviceName() {
      return CupertinoButton(
        onPressed: () {},
        padding: EdgeInsets.zero,
        child: SizedBox(
          key: const ValueKey('deviceName'),
          height: 50,
          child: CupertinoTextField(
            controller: _deviceNameTextFieldController,
            focusNode: _deviceFocusNode,
            placeholder: 'Enter device name',
            padding: const EdgeInsets.only(left: 0),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              final newDeviceInstance = widget.device.value
                  .copyWith(deviceName: _deviceNameTextFieldController.text);
              TPDeviceManager()
                  .updateDevice(newDeviceInstance, needToNotify: false);
              widget.device.value = newDeviceInstance;
            },
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    Widget deviceType() {
      return SizedBox(
        key: const ValueKey('deviceType'),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Type',
              textAlign: TextAlign.left,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.black,
                  ),
            ),
            Text(
              widget.device.value.deviceType.getTypeName(),
              textAlign: TextAlign.left,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey('generalWidget'),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          deviceName(),
          Divider(height: 0, color: Colors.grey[300]!),
          deviceType(),
        ],
      ),
    );
  }

  Widget _actionsWidget() {
    Widget bindingAction() {
      return CupertinoButton(
        onPressed: () {},
        padding: EdgeInsets.zero,
        child: SizedBox(
          key: const ValueKey('bindingActionWidget'),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Binding',
                textAlign: TextAlign.left,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: Colors.black,
                    ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      key: const ValueKey('actionsWidget'),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'ACTIONS',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: bindingAction(),
          )
        ],
      ),
    );
  }

  Widget _unpairWidget() {
    return CupertinoButton(
      onPressed: () {},
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SizedBox(
          height: 50,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Unpair Device',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
