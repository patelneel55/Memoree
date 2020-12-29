import 'package:flutter/material.dart';
import 'package:memoree_client/constants.dart';
import 'package:memoree_client/search.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  final bool isMobile, isTablet;

  CustomAppBar({Key key, @required this.isMobile, @required this.isTablet}) : super(key : key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      elevation: 1,
      // automaticallyImplyLeading: false,
      flexibleSpace: Container(),
      centerTitle: true,  
      title: Row(
        children: <Widget>[
          Text(PageTitles.appName),
          if(!widget.isTablet)
            Flexible(
              flex: 5,
              child: Container(
                constraints: BoxConstraints(minWidth: 100, maxWidth: 900),
                padding: const EdgeInsets.all(100.0),
                child: SearchWidget(),
              )
            ),
          // Expanded(flex: 2, child: Container())
        ],
      ),
      actions: <Widget>[
        if(widget.isTablet)
          Container(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0),
            child: IconButton(
              icon: const Icon(Icons.search_outlined),
              tooltip: ActionNames.search,
              splashRadius: 25,
              onPressed: () => {},
            ) 
          ),
        Container(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: ActionNames.upload,
            splashRadius: 25,
            onPressed: () => {}
          ),
        ),
        if(!widget.isMobile)
        Container(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: ActionNames.settings,
            splashRadius: 25,
            onPressed: () => {}
          ),
        ),
        Container(padding: const EdgeInsets.all(5.0)),
      ]
    );
  }
}