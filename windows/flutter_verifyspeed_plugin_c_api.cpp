#include "include/flutter_verifyspeed_plugin/flutter_verifyspeed_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_verifyspeed_plugin.h"

void FlutterVerifyspeedPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_verifyspeed_plugin::FlutterVerifyspeedPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
