import 'package:flutter/material.dart';

import 'package:memoree_client/app/services/firebase_auth.dart';
import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/widgets/account_info.dart';
import 'package:memoree_client/search.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  final bool isMobile, isTablet;

  CustomAppBar({Key key, @required this.isMobile, @required this.isTablet})
      : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(65);
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
            Text(PageTitles.appName, style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(width: 8,),
            if (!widget.isTablet)
              Flexible(
                  flex: 5,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 900),
                    padding: const EdgeInsets.all(100.0),
                    child: SearchWidget(),
                  )),
            // Expanded(flex: 2, child: Container())
          ],
        ),
        actions: <Widget>[
          if (widget.isTablet)
            Container(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: IconButton(
                  icon: const Icon(Icons.search_outlined),
                  tooltip: ActionNames.search,
                  splashRadius: 25,
                  onPressed: () => {},
                )),
          Container(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0),
            child: IconButton(
                icon: const Icon(Icons.cloud_upload_outlined),
                tooltip: ActionNames.upload,
                splashRadius: 25,
                onPressed: () => {}),
          ),
          if (!widget.isMobile)
            Container(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0),
              child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: ActionNames.settings,
                  splashRadius: 25,
                  onPressed: () => {}),
            ),
          if (!widget.isMobile)
            Container(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: FutureBuilder(
                future: FirebaseAuthService().currentUser(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return Material(
                        color: Colors.transparent,
                        child: InkWell( 
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              barrierDismissible: true,
                              builder: (context) {
                                return Align(
                                  alignment: Alignment(0.98, -0.79),
                                  child: Material(
                                    shape:
                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                    child: Container(
                                      width: 300,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5.0),
                                        boxShadow: [
                                          BoxShadow(blurRadius: 1.0),
                                        ]
                                      ),
                                      child: AccountInfo(),
                                    ), 
                                  ),
                                );
                              }
                            );
                          },
                          splashColor: Colors.grey,
                          customBorder: CircleBorder(),
                          child: Tooltip(
                            message: "Google Account\n" + snapshot.data.displayName + "\n" + snapshot.data.email,
                            padding: const EdgeInsets.all(2.0),
                            child: CircleAvatar(
                              radius: 15,
                              child: ClipOval(
                                child: Image.network(snapshot.data.photoUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        )
                      );
                      break;
                  }
                  return Container();
                },
              ),
            ),
          Container(padding: const EdgeInsets.all(5.0)),
        ]);
  }
}
