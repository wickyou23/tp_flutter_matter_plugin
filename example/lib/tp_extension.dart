import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  void showSnackBar({String message = "", Color textColor = Colors.black}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey,
          content: Text(
            message,
            style: CupertinoTheme.of(this).textTheme.textStyle.copyWith(
                  color: textColor,
                ),
          ),
        ),
      );
  }

  void showiOSLoading() {
    showCupertinoDialog(
      routeSettings: const RouteSettings(name: '/showiOSLoading'),
      context: this,
      builder: ((context) {
        return Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const CupertinoActivityIndicator(),
          ),
        );
      }),
    );
  }

  void hideiOSLoading() {
    bool loadingIsCurrent = false;
    Navigator.of(this).popUntil((route) {
      if (!loadingIsCurrent) {
        loadingIsCurrent =
            route.settings.name == '/showiOSLoading' && route.isCurrent;
      }

      return true;
    });

    if (loadingIsCurrent) {
      Navigator.of(this).pop();
    }
  }
}
