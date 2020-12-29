import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {

    return TextFormField(
      decoration: InputDecoration(
        labelText: "Search",
        contentPadding: EdgeInsets.all(10.0),
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: new BorderSide()
        )
      ),
    );
  }
}