import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_desktop_file_manager/flutter_desktop_file_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterDesktopFileManagerPlugin = FlutterDesktopFileManager();

  dynamic isDarkMode = false;
  @override
  void initState() {
    super.initState();
    initPlatformState();

    updateIsDarkMode();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterDesktopFileManagerPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void updateIsDarkMode() {
    _flutterDesktopFileManagerPlugin.onGetDarkMode().then(
      (value) {
        print("onGetDarkMode ${value}");
        setState(() {
          isDarkMode = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              children: [
                MaterialButton(
                  onPressed: () {
                    print("on click select file");
                    _flutterDesktopFileManagerPlugin.OnSelectFile();
                  },
                  child: const Text("select file"),
                ),
                MaterialButton(
                  onPressed: () {
                    _flutterDesktopFileManagerPlugin.onUpdateDarkMode(false);
                    updateIsDarkMode();
                  },
                  child: const Text("onSetDarkMode is false"),
                ),
                MaterialButton(
                  onPressed: () {
                    _flutterDesktopFileManagerPlugin.tryWriteImageFromClipboard("abc.png");
                    
                  },
                  child: const Text("tryWriteImageFromClipboard"),
                ),
                MaterialButton(
                  onPressed: () {
                    _flutterDesktopFileManagerPlugin.onUpdateDarkMode(true);
                    updateIsDarkMode();
                  },
                  child: const Text("onSetDarkMode is true"),
                ),
                Text(isDarkMode.toString())
              ],
            ),
          )),
    );
  }
}
