import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_desktop_file_manager_platform_interface.dart';

/// An implementation of [FlutterDesktopFileManagerPlatform] that uses method channels.
class MethodChannelFlutterDesktopFileManager extends FlutterDesktopFileManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_desktop_file_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?>  onSelectFile() async { 
    final path = await methodChannel.invokeMethod<String>('onSelectFileManager');
    print("onSelectFile ${path}");
    return path;
  }

  @override
  Future<void> onUpdateDarkMode(bool darkMode) async {
     await methodChannel.invokeMethod<String>('updateDarkMode', <String, Object>{'darkMode': darkMode});
  }

  @override
  Future<bool> onGetDarkMode() async {
     final darkMode = await methodChannel.invokeMethod<bool>('getDarkMode');
     return darkMode??false;
  }
}
