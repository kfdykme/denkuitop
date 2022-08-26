#include "include/flutter_desktop_file_manager/flutter_desktop_file_manager_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_desktop_file_manager_plugin.h"

void FlutterDesktopFileManagerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_desktop_file_manager::FlutterDesktopFileManagerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
