
import 'flutter_desktop_file_manager_platform_interface.dart';

class FlutterDesktopFileManager {
  Future<String?> getPlatformVersion() {
    return FlutterDesktopFileManagerPlatform.instance.getPlatformVersion();
  }
  

  Future<String?> OnSelectFile() {
    return FlutterDesktopFileManagerPlatform.instance.onSelectFile();
  }
}
