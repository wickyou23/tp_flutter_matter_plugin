import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_commission_device_manager.dart';

class TPCommissionLoading extends StatefulWidget {
  const TPCommissionLoading({super.key});

  @override
  State<TPCommissionLoading> createState() => _TPCommissionLoadingState();
}

class _TPCommissionLoadingState extends State<TPCommissionLoading> {
  late StreamSubscription<CommissionState> _subCommissionStream;
  final StreamController<CommissionState> _innerCommissionStream =
      StreamController<CommissionState>();

  @override
  void initState() {
    _subCommissionStream =
        TPCommissionDeviceManager.shared.state.stream.listen((event) {
      _innerCommissionStream.add(event);
    });

    super.initState();
  }

  @override
  void dispose() {
    _subCommissionStream.cancel();
    _innerCommissionStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: StreamBuilder(
          stream: _innerCommissionStream.stream,
          builder: (_, snapshot) {
            String processMsg = '';
            String title = 'Add Accessory';
            bool isDone = false;
            if (snapshot.data is DiscoverDeviceCommissionState) {
              processMsg = 'Discovering devices on the network...';
            } else if (snapshot.data is PairingDeviceCommissionState) {
              processMsg = 'Pairing device...';
            } else if (snapshot.data is CommissionSuccessState) {
              title = 'Completed!';
              isDone = true;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isDone)
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'resources/images/success.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                if (!isDone)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 50),
                        Flexible(
                          child: Text(
                            processMsg,
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isDone)
                  Center(
                    child: CupertinoButton.filled(
                      child: const Text('Done'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
    ;
  }
}
