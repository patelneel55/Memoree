import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/models/drawer_state.dart';
import 'package:memoree_client/app/models/search_state.dart';
import 'package:memoree_client/app/widgets/account_info.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;

  AppDrawer({this.isMobile, this.isTablet});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Consumer<DrawerModel>(
        builder: (__, drawer, _) {
          final String _selectedItem = Provider.of<DrawerModel>(context, listen: false).state;
          return Drawer(
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
                      DrawerItem(
                        icon: const Icon(Icons.movie_outlined),
                        text: PageTitles.videos,
                        selected: _selectedItem == PageTitles.videos,
                        onTap: () {
                          if(_selectedItem != PageTitles.videos)
                          {
                            Provider.of<DrawerModel>(context, listen: false).updatePage(PageTitles.videos);
                            Provider.of<SearchModel>(context, listen: false).clear();
                          }
                        },
                      ),
                      DrawerItem(
                        icon: const Icon(Icons.video_library_outlined),
                        text: PageTitles.folders,
                        selected: _selectedItem == PageTitles.folders,
                        onTap: () {
                          if(_selectedItem != PageTitles.folders)
                            Provider.of<DrawerModel>(context, listen: false).updatePage(PageTitles.folders);
                        }
                      ),
                    ],
                  )
                ),
              ],
            )
          );
        }
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key key,
    @required this.icon,
    @required this.text,
    @required this.selected,
    this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;
  final Icon icon;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25)
          ),
        ),
        selected: this.selected,
        selectedTileColor: Colors.blue.withOpacity(0.1),
        leading: this.icon,
        title: Text(this.text, style: TextStyle(fontWeight: FontWeight.w500)),
        onTap: this.onTap,
      ),
    );
  }
}