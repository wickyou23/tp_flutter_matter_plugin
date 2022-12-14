import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package/channels/tp_matter_helper.dart';
import 'package:tp_flutter_matter_package/models/tp_binding_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_flutter_matter_package.dart';
import 'package:tp_flutter_matter_package_example/custom_widgets/TPCupertinoSliverNavigationBarNoLargerTitle.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';

class TPDeviceBindingSetting extends StatefulWidget {
  static const routeName = '/TPDeviceBindingSetting';

  const TPDeviceBindingSetting({
    super.key,
    required this.rootDevice,
    required this.subDevice,
  });

  final ValueNotifier<TPDevice> rootDevice;
  final TPDevice subDevice;

  @override
  State<TPDeviceBindingSetting> createState() => _TPDeviceBindingSettingState();
}

class _TPDeviceBindingSettingState extends State<TPDeviceBindingSetting> {
  final ValueNotifier<List<ValueNotifier<_TPBindingDeviceCell>>>
      _filterDevices = ValueNotifier([]);
  final ValueNotifier<Map<TPDeviceClusterIDType, List<TPDevice>>>
      _deviceSeleted = ValueNotifier({});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _filterDevices.value = await _getBindingDevices();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: TPCupertinoSliverNavigationBarNoLargerTitle(
              context,
              title: 'Binding',
              previousPageTitle: widget.rootDevice.value.getDeviceName(),
              trailing: ValueListenableBuilder(
                valueListenable: _deviceSeleted,
                builder: (_, value, __) {
                  return Opacity(
                    opacity: value.isEmpty ? 0.3 : 1.0,
                    child: CupertinoButton(
                      onPressed: value.isEmpty
                          ? null
                          : () async {
                              await _saveBinding();
                            },
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Save',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .actionTextStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
            pinned: true,
            floating: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            sliver: ValueListenableBuilder(
              valueListenable: _filterDevices,
              builder: (_, value, __) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final item = value[index];
                      return ValueListenableBuilder(
                        valueListenable: item,
                        builder: ((_, __, ___) {
                          return _renderDeviceWidget(item);
                        }),
                      );
                    },
                    childCount: value.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderDeviceWidget(ValueNotifier<_TPBindingDeviceCell> itemNotifier) {
    final item = itemNotifier.value;
    if (item.isHeader) {
      return Container(
        key: ValueKey(item.clusterType.getTitle()),
        height: 45,
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container()),
            Text(
              item.clusterType.getTitle(),
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    } else {
      BorderRadius borderRadius = BorderRadius.zero;
      if (item.isBeginItem && item.isEndItem) {
        borderRadius = BorderRadius.circular(8);
      } else if (item.isBeginItem) {
        borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8));
      } else if (item.isEndItem) {
        borderRadius = const BorderRadius.only(
            bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8));
      }

      return Container(
        key: ValueKey(item.value!.deviceId),
        height: 50,
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: borderRadius),
        child: CupertinoButton(
          onPressed: () {
            var tmp = <TPDevice>[];
            if (!item.isSelected) {
              if (_deviceSeleted.value.containsKey(item.clusterType)) {
                tmp = _deviceSeleted.value[item.clusterType]!;
                tmp.add(item.value!);
              } else {
                tmp = [item.value!];
              }
            } else {
              if (_deviceSeleted.value.containsKey(item.clusterType)) {
                tmp = _deviceSeleted.value[item.clusterType]!;
                tmp.remove(item.value!);
                if (tmp.isEmpty) {
                  _deviceSeleted.value = Map.from(_deviceSeleted.value)
                    ..remove(item.clusterType);
                  itemNotifier.value =
                      item.copyWith(isSelected: !item.isSelected);
                  return;
                }
              }
            }

            _deviceSeleted.value = Map.from(_deviceSeleted.value)
              ..update(
                item.clusterType,
                (value) => tmp,
                ifAbsent: () => tmp,
              );

            itemNotifier.value = item.copyWith(isSelected: !item.isSelected);
          },
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Column(
              children: [
                Expanded(
                  child: Row(children: [
                    ImageIcon(
                      item.value!.getIcon(),
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.value!.getDeviceName(),
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
                    Visibility(
                      visible: item.isSelected,
                      child: const Icon(
                        Icons.check,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ]),
                ),
                if (!item.isEndItem) const Divider(height: 1),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<List<ValueNotifier<_TPBindingDeviceCell>>> _getBindingDevices() async {
    final List<ValueNotifier<_TPBindingDeviceCell>> filterDevices = [];
    final currentDevice = widget.subDevice;

    final currentBindingDatas =
        await TpFlutterMatterPlugin().readBindingDatasWithDevice(currentDevice);
    var currentBindingDevices = <TPBindingDevice>[];
    if (currentBindingDatas is TPMatterResponseSuccess<List<TPBindingDevice>>) {
      currentBindingDevices = currentBindingDatas.data ?? [];
    }

    await TPDeviceManager()
        .syncBindingDevices(currentDevice, currentBindingDevices);

    final deviceGroup = await TPDeviceManager()
        .getDevicesMappingWithBindingDevice(bindingDevice: currentDevice);
    for (var clusterType in currentDevice.bindingClusterControllers) {
      if (!deviceGroup.containsKey(clusterType)) {
        continue;
      }

      filterDevices.add(ValueNotifier(
        _TPBindingDeviceCell(clusterType: clusterType, isHeader: true),
      ));

      final deivceList = deviceGroup[clusterType]!;
      for (var device in deivceList) {
        final isSelected = currentDevice.bindingDevices.firstWhereOrNull(
                (element) =>
                    element.cluster == clusterType.value &&
                    element.deviceId.toString() == device.deviceId &&
                    element.endpoint == device.endpoint) !=
            null;

        if (isSelected) {
          if (_deviceSeleted.value.containsKey(clusterType)) {
            final tmp = _deviceSeleted.value[clusterType]!;
            tmp.add(device);
          } else {
            _deviceSeleted.value.update(
              clusterType,
              (value) => [device],
              ifAbsent: () => [device],
            );
          }
        }

        filterDevices.add(ValueNotifier(
          _TPBindingDeviceCell(
            clusterType: clusterType,
            value: device,
            isBeginItem: device.deviceId == deivceList.first.deviceId,
            isEndItem: device.deviceId == deivceList.last.deviceId,
            isSelected: isSelected,
          ),
        ));
      }
    }

    return filterDevices;
  }

  Future<void> _saveBinding() async {
    final plugin = TpFlutterMatterPlugin();
    final result = await plugin.saveBindingWithDevice(
        widget.subDevice, _deviceSeleted.value);
    if (!mounted) {
      return;
    }

    if (result is TPMatterResponseError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '[Error]: ${result.errorMessage}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.redAccent,
                  ),
            ),
          ),
        );
    } else if (result is TPMatterResponseSuccess) {
      final data = result.data;
      if (data is List<Map>) {
        TPDeviceManager().saveBindingDevicesWithDevice(widget.subDevice, data);
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '[Success]: Saved!',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: Colors.greenAccent,
                  ),
            ),
          ),
        );
    }
  }
}

class _TPBindingDeviceCell {
  const _TPBindingDeviceCell({
    required this.clusterType,
    this.value,
    this.isHeader = false,
    this.isBeginItem = false,
    this.isEndItem = false,
    this.isSelected = false,
  });

  final TPDeviceClusterIDType clusterType;
  final TPDevice? value;
  final bool isHeader;
  final bool isBeginItem;
  final bool isEndItem;
  final bool isSelected;

  _TPBindingDeviceCell copyWith({
    TPDeviceClusterIDType? clusterType,
    TPDevice? value,
    bool? isHeader,
    bool? isBeginItem,
    bool? isEndItem,
    bool? isSelected,
  }) {
    return _TPBindingDeviceCell(
      clusterType: clusterType ?? this.clusterType,
      value: value ?? this.value,
      isHeader: isHeader ?? this.isHeader,
      isBeginItem: isBeginItem ?? this.isBeginItem,
      isEndItem: isEndItem ?? this.isEndItem,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
