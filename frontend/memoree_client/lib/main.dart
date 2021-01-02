import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/pages/login.dart';
import 'package:memoree_client/app/models/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: PageTitles.appName,
        theme: AppTheme.lightTheme,
        home: LoginPage());
  }
}
