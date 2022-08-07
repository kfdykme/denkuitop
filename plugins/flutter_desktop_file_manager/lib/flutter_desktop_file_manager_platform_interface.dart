import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_desktop_file_manager_method_channel.dart';

abstract class FlutterDesktopFileManagerPlatform extends PlatformInterface {
  /// Constructs a FlutterDesktopFileManagerPlatform.
  FlutterDesktopFileManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDesktopFileManagerPlatform _instance = MethodChannelFlutterDesktopFileManager();

  /// The default instance of [FlutterDesktopFileManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDesktopFileManager].
  static FlutterDesktopFileManagerPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDesktopFileManagerPlatform] when
  /// they register themselves.
  static set instance(FlutterDesktopFileManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> onSelectFile() {
    throw UnimplementedError('onSelectFile() has not been implemented.');
  }
}
