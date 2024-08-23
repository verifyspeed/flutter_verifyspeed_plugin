import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  VerifySpeedPlugin.instance.setClientKey('YOUR_CLIENT_KEY');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      await VerifySpeedPlugin.instance.notifyOnResumed();
    }
  }

  Future<void> startVerification(
    VerifySpeedMethodType type,
  ) =>
      VerifySpeedPlugin.instance
          .startVerification(
            onFailure: (error) {
              log('Error: ${error.message}');
            },
            onSuccess: (token) {
              log('Token: $token');
            },
            type: type,
          )
          .catchError(
            (error, stackTrace) => log('Error on init: $error'),
          );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => startVerification(
                VerifySpeedMethodType.telegram,
              ),
              child: const Text('Start Verification With Telegram'),
            ),
            ElevatedButton(
              onPressed: () => startVerification(
                VerifySpeedMethodType.whatsapp,
              ),
              child: const Text('Start Verification With WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}
