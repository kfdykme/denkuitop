import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_cef_web/flutter_desktop_cef_web.dart';

class KffToNavigator extends NavigatorObserver {

  static bool isShowingDialog = false;

  static Function refresh = null;

  static Future refreshFuture = null;

  static Timer timer;
  void doRefresh() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = Timer(Duration(milliseconds: 200), () {
      // func?.call();
      if (refresh != null) {
        refresh();
      }
    });
  }

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);

    refresh = () {

      FlutterDesktopCefWeb.allWebViews.forEach((element) { 
        element.show();
      });
      KffToNavigator.isShowingDialog = false;
    };
    doRefresh();
  }

  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);

    refresh = () {

      FlutterDesktopCefWeb.allWebViews.forEach((element) { 
        element.hide();
      });

      KffToNavigator.isShowingDialog = true;
    };

    doRefresh();
  }
}

