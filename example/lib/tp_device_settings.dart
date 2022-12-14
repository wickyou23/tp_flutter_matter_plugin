import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/TPCupertinoSliverNavigationBarNoLargerTitle.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';
import 'package:tp_flutter_matter_package_example/tp_device_setting_details.dart';

class TPDeviceSettings extends StatelessWidget {
  static const String routeName = '/TPDeviceSettings';

  List<ValueNotifier<TPDevice>> get _devices => TPDeviceManager().devices;

  const TPDeviceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: TPCupertinoSliverNavigationBarNoLargerTitle(
              context,
              title: 'Device Settings',
              previousPageTitle: 'Home',
            ),
            pinned: true,
            floating: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) {
                  final item = _devices[index];
                  BorderRadius borderRadius = BorderRadius.zero;
                  if (_devices.length == 1) {
                    borderRadius = BorderRadius.circular(8);
                  } else if (index == 0) {
                    borderRadius = const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8));
                  } else if (index == _devices.length - 1) {
                    borderRadius = const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8));
                  }

                  return ValueListenableBuilder(
                    valueListenable: item,
                    builder: ((_, device, __) {
                      return CupertinoButton(
                        onPressed: (() {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  TPDeviceSettingDetails(device: item),
                              settings: const RouteSettings(
                                  name: TPDeviceSettingDetails.routeName),
                            ),
                          );
                        }),
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: borderRadius),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(children: [
                                  ImageIcon(
                                    device.getIcon(),
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    device.getDeviceName(),
                                    textAlign: TextAlign.left,
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .copyWith(
                                          color: Colors.black,
                                        ),
                                  ),
                                  Expanded(child: Container()),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ]),
                              ),
                              if (index < _devices.length)
                                const Divider(height: 1),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
                childCount: _devices.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
