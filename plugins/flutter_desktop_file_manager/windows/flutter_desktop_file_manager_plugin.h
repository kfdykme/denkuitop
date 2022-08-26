#ifndef FLUTTER_PLUGIN_FLUTTER_DESKTOP_FILE_MANAGER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_DESKTOP_FILE_MANAGER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_desktop_file_manager {

class FlutterDesktopFileManagerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterDesktopFileManagerPlugin();

  virtual ~FlutterDesktopFileManagerPlugin();

  // Disallow copy and assign.
  FlutterDesktopFileManagerPlugin(const FlutterDesktopFileManagerPlugin&) = delete;
  FlutterDesktopFileManagerPlugin& operator=(const FlutterDesktopFileManagerPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_desktop_file_manager

#endif  // FLUTTER_PLUGIN_FLUTTER_DESKTOP_FILE_MANAGER_PLUGIN_H_
