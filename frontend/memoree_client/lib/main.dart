import 'package:flutter/material.dart';
import 'package:memoree_client/search.dart';
import 'package:memoree_client/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const String _app_title = "Memoree";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _app_title,
      theme: AppTheme.lightTheme,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final String appTitle = "Memoree";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(),
    );
  }

  AppBar appBar()
  {
    return AppBar(
      toolbarHeight: 75,
      elevation: 1,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(),
      centerTitle: true,
        title: Row(
          children: <Widget>[
            Text("Memoree"),
            Flexible(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(100.0),
                child: SearchWidget(),
              )
            ),
            Expanded(flex: 2, child: Container())
          ],
        ),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0),
            child: IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: "Upload",
              splashRadius: 25,
              onPressed: () => {}
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: "Settings",
              splashRadius: 25,
              onPressed: () => {}
            ),
          ),
        ]
      );
  }
}