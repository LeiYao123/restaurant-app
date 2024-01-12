import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'inapp_webview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => url = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'input url',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!url.contains('http')) {
                  Get.snackbar('Error', '请输入正确 URL');
                  return;
                }
                Get.to(() => InAppwebview(url: url));
              },
              child: const Text('open web page'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.to(
                  () => const InAppwebview(
                      url: 'https://order.malasichuan.com/locations'),
                );
              },
              child: const Text('open malasichuan web page'),
            ),
          ],
        ),
      ),
    );
  }
}
