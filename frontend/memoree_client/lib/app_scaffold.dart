import 'package:flutter/material.dart';
import 'package:memoree_client/search.dart';
import 'constants.dart';
import 'drawer.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobileLayout = MediaQuery.of(context).size.width < 600;
    final bool isTabletLayout = MediaQuery.of(context).size.width < 1008;

    return Scaffold(
      appBar: appBar(isMobileLayout, isTabletLayout),
      drawer: appDrawer(isMobileLayout, isTabletLayout),
      body: Row(
        children: <Widget>[
          if(!isMobileLayout)
            AppDrawer()
        ]
      ),
    );
  }

  AppBar appBar(bool isMobile, bool isTablet)
  {
    return AppBar(
      toolbarHeight: 75,
      elevation: 1,
      // automaticallyImplyLeading: false,
      flexibleSpace: Container(),
      centerTitle: true,  
      title: Row(
        children: <Widget>[
          Text(PageTitles.appName),
          if(!isTablet)
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
        if(isTablet)
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
        if(!isMobile)
        Container(
          padding: const EdgeInsets.only(right: 15.0, left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: ActionNames.settings,
            splashRadius: 25,
            onPressed: () => {}
          ),
        ),
      ]
    );
  }

  Widget appDrawer(bool isMobile, bool isTablet)
  {
    if(isMobile)
      return AppDrawer();

    return null;
  }
}