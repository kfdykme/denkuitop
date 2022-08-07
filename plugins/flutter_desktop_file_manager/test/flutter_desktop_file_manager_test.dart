import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_desktop_file_manager/flutter_desktop_file_manager.dart';
import 'package:flutter_desktop_file_manager/flutter_desktop_file_manager_platform_interface.dart';
import 'package:flutter_desktop_file_manager/flutter_desktop_file_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDesktopFileManagerPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterDesktopFileManagerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterDesktopFileManagerPlatform initialPlatform = FlutterDesktopFileManagerPlatform.instance;

  test('$MethodChannelFlutterDesktopFileManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDesktopFileManager>());
  });

  test('getPlatformVersion', () async {
    FlutterDesktopFileManager flutterDesktopFileManagerPlugin = FlutterDesktopFileManager();
    MockFlutterDesktopFileManagerPlatform fakePlatform = MockFlutterDesktopFileManagerPlatform();
    FlutterDesktopFileManagerPlatform.instance = fakePlatform;
  
    expect(await flutterDesktopFileManagerPlugin.getPlatformVersion(), '42');
  });
}
