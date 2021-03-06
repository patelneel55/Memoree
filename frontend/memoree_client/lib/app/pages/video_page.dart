import 'package:flutter/material.dart';
import 'package:memoree_client/app/services/search.dart';

import 'package:memoree_client/app/widgets/grid_results.dart';

class VideoPage extends StatelessWidget {
  final String searchQuery;

  VideoPage(this.searchQuery);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SearchService.fetchSearchResults(this.searchQuery),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 5, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 9,
                          child: Text("Results for: " + this.searchQuery, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.w500),),
                        ),
                        // Expanded(
                        //   flex: 2,
                        //   child: Text("98%", textAlign: TextAlign.right,)
                        // )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Divider(height: 1, thickness: 1.5,)
                  ),
                  Expanded(
                    child: ContentGrid(
                      videoDataList: snapshot.data
                    ),
                  ),
                ],
              )
            );
            break;
        }
        return Container();
      }
    );
  }
}