
import 'flutter_desktop_file_manager_platform_interface.dart';

class FlutterDesktopFileManager {
  Future<String?> getPlatformVersion() {
    return FlutterDesktopFileManagerPlatform.instance.getPlatformVersion();
  }
  

  Future<String?> OnSelectFile() {
    return FlutterDesktopFileManagerPlatform.instance.onSelectFile();
  }

  Future<void> onUpdateDarkMode(bool darkMode) {
    return FlutterDesktopFileManagerPlatform.instance.onUpdateDarkMode(darkMode);
  }

  Future<bool> onGetDarkMode() {
    return FlutterDesktopFileManagerPlatform.instance.onGetDarkMode();
  }
}
