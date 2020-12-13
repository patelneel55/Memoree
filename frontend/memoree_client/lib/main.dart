import 'package:flutter/material.dart';
import 'package:memoree_client/app_scaffold.dart';
import 'package:memoree_client/constants.dart';
import 'package:memoree_client/drawer.dart';
import 'package:memoree_client/search.dart';
import 'package:memoree_client/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: PageTitles.appName,
      theme: AppTheme.lightTheme,
      home: AppScaffold(),
      // initialRoute: RouteNames.videos,
      // navigatorObservers: [],
      // routes: {
      //   RouteNames.videos: (_) => HomePage(),
      // }
    );
  }
}

// class HomePage extends StatefulWidget {

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(),
//       body: Row(
//         children: <Widget>[
//           AppDrawer()
//         ]
//       ),
//     );
//   }

//   AppBar appBar()
//   {
//     return AppBar(
//       toolbarHeight: 75,
//       elevation: 1,
//       automaticallyImplyLeading: false,
//       flexibleSpace: Container(),
//       centerTitle: true,
//         title: Row(
//           children: <Widget>[
//             Text(PageTitles.appName),
//             Flexible(
//               flex: 5,
//               child: Container(
//                 padding: const EdgeInsets.all(100.0),
//                 child: SearchWidget(),
//               )
//             ),
//             Expanded(flex: 2, child: Container())
//           ],
//         ),
//         actions: <Widget>[
//           Container(
//             padding: const EdgeInsets.only(right: 10.0, left: 10.0),
//             child: IconButton(
//               icon: const Icon(Icons.cloud_upload_outlined),
//               tooltip: ActionNames.upload,
//               splashRadius: 25,
//               onPressed: () => {}
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.only(right: 10.0, left: 10.0),
//             child: IconButton(
//               icon: const Icon(Icons.settings_outlined),
//               tooltip: ActionNames.settings,
//               splashRadius: 25,
//               onPressed: () => {}
//             ),
//           ),
//         ]
//       );
//   }
// }