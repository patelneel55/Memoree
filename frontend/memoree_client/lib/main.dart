import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/pages/login.dart';
import 'package:memoree_client/app/models/themes.dart';

Future main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: PageTitles.appName,
              theme: AppTheme.lightTheme,
              home: LoginPage());
            break;
        }
        return Container();
      }
    );
  }
}
