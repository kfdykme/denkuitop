 
import 'dart:isolate';

import 'package:denkuitop/denkui/page/DenkuiPage.dart';
// import 'package:denkuitop/denkui/submodule/SubModuleManager.dart';
import 'package:denkuitop/kfto/page/KfToHomePage.dart';
import 'package:denkuitop/native/KeydownManager.dart';
import 'package:denkuitop/native/LibraryLoader.dart';
import 'package:denkuitop/remote/base/BaseRemotePage.dart';
import 'package:denkuitop/uitest/KeyEventTest.dart';
import 'package:denkuitop/uitest/SnackTest.dart';
import 'package:flutter/material.dart';

import 'package:denkuitop/denkui/child_process/ChildProcess.dart';

void doWork(SendPort sendPort) {
  
  KeydownManager.ins.RegisterHotKeyEvent("ctrl-s", () {
    print("save ");
  });
}

void main() {
  //child process
  // SubModuleManager().setup(setupCallback: () {
  //   ChildProcess(ChildProcess.DENO_COMMAND).run(callback: () {
  //     print("Run Success");
  //   });
  // }); 
  // KeydownManager.ins.RegisterHotKeyEvent("ctrl-s", () {
  //   print("save ");
  // });
  // ReceivePort rp = new ReceivePort();

  // Isolate.spawn(doWork, rp.sendPort);
  runApp(MyApp());
  // runApp(SnackApp());
  // runApp(KeyEventTestApp());
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
        // fontFamily: 'msyh',
        appBarTheme: null,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: KfToHomePage()
    );
  }
}
