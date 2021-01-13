import 'package:flutter/material.dart';
import 'package:memoree_client/app/models/drawer_state.dart';
import 'package:memoree_client/app/models/search_state.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(input) {
    setState(() {
      Provider.of<SearchModel>(context, listen: false).updateQuery(input);
      Provider.of<DrawerModel>(context, listen: false).home();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Search",
        filled: true,
        contentPadding: EdgeInsets.all(10.0),
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(),
        ),
      ),
      controller: _textController,
      onFieldSubmitted: (input) {
        _textController.clear();
        if(input != "")
          _updateSearchQuery(input);
      },
    );
  }
}
