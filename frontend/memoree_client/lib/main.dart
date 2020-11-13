import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const String _app_title = "Memoree";

    return MaterialApp(
      title: _app_title,
      theme: ThemeData(
        fontFamily: "OpenSans",
        primaryColor: Colors.white
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memoree"),
        elevation: 2,
        actions: <Widget>[
          // searchBar(),

        ]
      ),
    );
  }

  Widget searchBar()
  {

  }
}