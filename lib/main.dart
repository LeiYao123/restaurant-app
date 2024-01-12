import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'pages/home/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Rushable',
    initialRoute: '/home',
    getPages: [
      GetPage(name: '/home', page: () => const HomePage()),
    ],
  ));
}
