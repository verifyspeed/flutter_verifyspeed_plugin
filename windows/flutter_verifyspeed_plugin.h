#ifndef FLUTTER_PLUGIN_FLUTTER_VERIFYSPEED_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_VERIFYSPEED_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_verifyspeed_plugin {

class FlutterVerifyspeedPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterVerifyspeedPlugin();

  virtual ~FlutterVerifyspeedPlugin();

  // Disallow copy and assign.
  FlutterVerifyspeedPlugin(const FlutterVerifyspeedPlugin&) = delete;
  FlutterVerifyspeedPlugin& operator=(const FlutterVerifyspeedPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_verifyspeed_plugin

#endif  // FLUTTER_PLUGIN_FLUTTER_VERIFYSPEED_PLUGIN_H_
