//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_desktop_cef_web/flutter_desktop_cef_web_plugin.h>
#include <flutter_desktop_file_manager/flutter_desktop_file_manager_plugin_c_api.h>
#include <libdeno_plugin/libdeno_plugin.h>
#include <native_hotkey/native_hotkey_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterDesktopCefWebPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterDesktopCefWebPlugin"));
  FlutterDesktopFileManagerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterDesktopFileManagerPluginCApi"));
  LibdenoPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LibdenoPlugin"));
  NativeHotkeyPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NativeHotkeyPlugin"));
}
