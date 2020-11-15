import 'package:flutter/material.dart';
import 'package:memoree_client/constants.dart';

class AppDrawer extends StatefulWidget {

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0.5,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.movie_outlined),
                  title: const Text(PageTitles.videos),
                  onTap: () => {},
                ),
                ListTile(
                  leading: const Icon(Icons.video_library_outlined),
                  title: const Text(PageTitles.folders),
                  onTap: () => {},
                ),
              ],
            )
          ),
        ],
      )
    );
  }
}