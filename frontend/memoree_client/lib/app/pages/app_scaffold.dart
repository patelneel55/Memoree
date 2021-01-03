import 'package:flutter/material.dart';

import 'package:memoree_client/app/pages/video_page.dart';
import 'package:memoree_client/app/widgets/app_bar.dart';
import 'package:memoree_client/app/widgets/drawer.dart';

class AppScaffold extends StatelessWidget {
  final String page;
  const AppScaffold({Key key, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobileLayout = MediaQuery.of(context).size.width < 600;
    final bool isTabletLayout = MediaQuery.of(context).size.width < 1008;

    return Scaffold(
        appBar:
            CustomAppBar(isMobile: isMobileLayout, isTablet: isTabletLayout),
        drawer: isMobileLayout ? AppDrawer(isMobile: isMobileLayout,) : null,
        body: SafeArea(
            child: Container(
                child: Row(children: <Widget>[
          if (!isMobileLayout) AppDrawer(isMobile: isMobileLayout,),
          Container(
              child: Expanded(child: VideoPage("earth")))
        ]))));
  }
}
