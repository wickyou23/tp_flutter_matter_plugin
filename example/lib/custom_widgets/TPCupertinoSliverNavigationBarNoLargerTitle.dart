import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TPCupertinoSliverNavigationBarNoLargerTitle
    extends SliverPersistentHeaderDelegate {
  TPCupertinoSliverNavigationBarNoLargerTitle(this.mainContext,
      {this.key, this.title = '', this.previousPageTitle = ''});

  final BuildContext mainContext;
  final String title;
  final String previousPageTitle;
  final Key? key;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final alpha = (min(shrinkOffset, 32) / 32 * 255).toInt();
    return CupertinoNavigationBar(
      key: key,
      backgroundColor: CupertinoColors.white.withAlpha(alpha),
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[400]!.withAlpha(alpha),
          width: 0.0, // 0.0 means one physical pixel
        ),
      ),
      middle: Text(
        title,
        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              color: Colors.black,
            ),
      ),
      previousPageTitle: previousPageTitle,
    );
  }

  @override
  double get maxExtent => MediaQuery.of(mainContext).padding.top + 44.0;

  @override
  double get minExtent => MediaQuery.of(mainContext).padding.top + 44.0;

  @override
  bool shouldRebuild(
      covariant TPCupertinoSliverNavigationBarNoLargerTitle oldDelegate) {
    return oldDelegate.title != title;
  }
}
