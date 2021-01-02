import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/widgets/account_info.dart';

class AppDrawer extends StatefulWidget {
  final isMobile;

  AppDrawer({this.isMobile});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        elevation: 0.5,
        child: Row(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 25.0),
                children: <Widget>[
                  if(widget.isMobile)
                    AccountInfo(),
                  if(widget.isMobile)
                    Divider(thickness: 2.0),
                  ListTile(
                    leading: const Icon(Icons.movie_outlined),
                    title: const Text(PageTitles.videos, style: TextStyle(fontWeight: FontWeight.w500)),
                    selected: _selectedIndex == 0,
                    onTap: () => { },
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_library_outlined),
                    title: const Text(PageTitles.folders, style: TextStyle(fontWeight: FontWeight.w500)),
                    selected: _selectedIndex == 1,
                    onTap: () => {},
                  ),
                ],
              )
            ),
          ],
        )
      ),
    );
  }
}