#include "flutter_desktop_file_manager_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <ShlObj.h>
// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace flutter_desktop_file_manager {

  std::string getString(const flutter::EncodableMap *args, std::string key)
  {
    auto status_it = args->find(flutter::EncodableValue(key));
    std::string res = "";
    if (status_it != args->end())
    {
      auto str = std::get<std::string>(status_it->second);
      std::cout << "get " << key.c_str() << ": " << str.c_str() << std::endl;
      res = str;
    }
    return res;
  }

  int getInt(const flutter::EncodableMap *args, std::string key)
  {
    int res = 0;
    auto res_str = getString(args, key);
    if (!res_str.empty())
    {
      res = std::stoi(res_str);
    }
    return res;
  }
// static
void FlutterDesktopFileManagerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_desktop_file_manager",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterDesktopFileManagerPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterDesktopFileManagerPlugin::FlutterDesktopFileManagerPlugin() {}

FlutterDesktopFileManagerPlugin::~FlutterDesktopFileManagerPlugin() {}

void FlutterDesktopFileManagerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
 

  if (method_call.method_name().compare("onSelectFileManager") == 0) {

    TCHAR szBuffer[MAX_PATH] = {0};
    
    BROWSEINFO bInfo = {0};
     
    bInfo.hwndOwner = GetForegroundWindow();
    bInfo.lpszTitle = TEXT("Select Directory");
    bInfo.ulFlags = BIF_RETURNONLYFSDIRS | BIF_USENEWUI | BIF_UAHINT;
    LPITEMIDLIST lpDlist;
    lpDlist = SHBrowseForFolder(&bInfo);
    if (lpDlist != NULL) {
      SHGetPathFromIDList(lpDlist, szBuffer);
      int iLen = WideCharToMultiByte(CP_ACP, 0, szBuffer, -1, NULL, 0, NULL, NULL);
      char * path_c = new char[iLen * sizeof(char)];
      WideCharToMultiByte(CP_ACP, 0, szBuffer, -1, path_c, iLen, NULL,NULL);
      
      result->Success(flutter::EncodableValue(std::string(path_c)));
    }


  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_desktop_file_manager
