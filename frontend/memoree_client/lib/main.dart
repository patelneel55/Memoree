import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memoree_client/app/models/user.dart';
import 'package:memoree_client/app/services/firebase_auth.dart';
import 'package:memoree_client/app_scaffold.dart';
import 'package:memoree_client/constants.dart';
import 'package:memoree_client/pages/login.dart';
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
        home: LoginPage());
  }
}
