import 'package:flutter/material.dart';
import 'package:playcric/core/url_strings.dart';
import 'package:playcric/features/pages/custom_web_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Play-Cric',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CustomInAppBrowser(url: UrlStrings.baseUrl),
    );
  }
}
