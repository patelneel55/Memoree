import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memoree_client/app/pages/landing.dart';
import 'package:memoree_client/app/widgets/wip.dart';
import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/models/drawer_state.dart';
import 'package:memoree_client/app/models/search_state.dart';
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawerModel()),
        ChangeNotifierProvider(create: (_) => SearchModel()),
      ],
      child: Scaffold(
        appBar: CustomAppBar(isMobile: isMobileLayout, isTablet: isTabletLayout),
        drawer: isMobileLayout ? AppDrawer(isMobile: isMobileLayout, isTablet: isTabletLayout,) : null,
        body: SafeArea(
          child: Container(
            child: Row(
              children: <Widget>[
                if (!isMobileLayout) 
                  AppDrawer(isMobile: isMobileLayout,isTablet: isTabletLayout,),
                Container(
                  child: Expanded(
                    child: Consumer2<SearchModel, DrawerModel>(
                      builder: (_, search, drawer, __) {
                        switch(drawer.state)
                        {
                          case PageTitles.videos:
                            return Container(
                              child: search.query == null ? 
                                LandingPage() :
                                VideoPage(search.query)
                            );
                            break;
                          case PageTitles.folders:
                            return WIP();
                            break;
                          default:
                            return Container();
                            break;
                        }
                      }
                    ),
                  )
                ),
              ]
            )
          )
        )
      ),
    );
  }
}