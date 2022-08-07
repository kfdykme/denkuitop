import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_desktop_file_manager/flutter_desktop_file_manager_method_channel.dart';

void main() {
  MethodChannelFlutterDesktopFileManager platform = MethodChannelFlutterDesktopFileManager();
  const MethodChannel channel = MethodChannel('flutter_desktop_file_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
