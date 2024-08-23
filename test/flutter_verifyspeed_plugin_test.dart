// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin.dart';
// import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin_platform_interface.dart';
// import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterVerifyspeedPluginPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterVerifyspeedPluginPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterVerifyspeedPluginPlatform initialPlatform = FlutterVerifyspeedPluginPlatform.instance;

//   test('$MethodChannelFlutterVerifyspeedPlugin is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterVerifyspeedPlugin>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterVerifyspeedPlugin flutterVerifyspeedPlugin = FlutterVerifyspeedPlugin();
//     MockFlutterVerifyspeedPluginPlatform fakePlatform = MockFlutterVerifyspeedPluginPlatform();
//     FlutterVerifyspeedPluginPlatform.instance = fakePlatform;

//     expect(await flutterVerifyspeedPlugin.getPlatformVersion(), '42');
//   });
// }
