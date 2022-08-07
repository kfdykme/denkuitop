import 'package:flutter/material.dart';
import 'package:flutter_desktop_cef_web/flutter_desktop_cef_web.dart';

class KffToNavigator extends NavigatorObserver {

  static bool isShowingDialog = false;

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    FlutterDesktopCefWeb.allWebViews.forEach((element) { 
      element.show();
    });
    KffToNavigator.isShowingDialog = false;
  }

  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);

    FlutterDesktopCefWeb.allWebViews.forEach((element) { 
      element.hide();
    });

    KffToNavigator.isShowingDialog = true;
  }
}

