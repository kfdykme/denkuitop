import 'dart:isolate';

// import 'package:denkuitop/denkui/submodule/SubModuleManager.dart';
import 'package:denkuitop/kfto/page/KfToHomePage.dart';
import 'package:denkuitop/kfto/page/KfToNavigator.dart';
import 'package:denkuitop/native/DenoManager.dart';
import 'package:denkuitop/native/KeydownManager.dart';
import 'package:flutter/material.dart';

void doWork(SendPort sendPort) {
  KeydownManager.ins.RegisterHotKeyEvent("ctrl-s", () {
    print("save ");
  });
}

void main() {
  runApp(MyApp());
  DenoManager.Instance().startDeno();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          backgroundColor: Colors.white,
          fontFamily: 'msyh',
          appBarTheme: null,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        navigatorObservers: [KffToNavigator()],
        home: KfToHomePage());
  }
}
