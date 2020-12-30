import 'package:flutter/material.dart';
import 'package:memoree_client/widgets/app_bar.dart';
import 'package:memoree_client/widgets/grid_results.dart';
import 'drawer.dart';

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
        drawer: isMobileLayout ? AppDrawer() : null,
        body: SafeArea(
            child: Container(
                child: Row(children: <Widget>[
          if (!isMobileLayout) AppDrawer(),
          Container(
              child: Expanded(child: page == "videos" ? ContentGrid() : null))
        ]))));
  }

  Widget appDrawer(bool isMobile, bool isTablet) {
    if (isMobile) return AppDrawer();

    return null;
  }
}
