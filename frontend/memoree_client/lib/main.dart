import 'package:flutter/material.dart';
import 'package:memoree_client/app_scaffold.dart';
import 'package:memoree_client/constants.dart';
import 'package:memoree_client/drawer.dart';
import 'package:memoree_client/search.dart';
import 'package:memoree_client/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: PageTitles.appName,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => AppScaffold(),
        '/login': (context) => Text("Under construction")
      }
    );
  }
}
