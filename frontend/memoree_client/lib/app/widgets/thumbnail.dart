import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/video_data.dart';

class ThumbnailGenerator extends StatelessWidget {
  final VideoData videoData;
  final bool dryrun;

  ThumbnailGenerator({this.videoData, this.dryrun = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dryrun ? Future.delayed(Duration(seconds: 3)) : videoData.getThumbnail(),
      builder: (BuildContext context,snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return dryrun ? 
              Image.network('https://picsum.photos/250?image=9', fit: BoxFit.cover,) : 
              snapshot.data ?? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: Colors.black54,),
                    SizedBox(height: 20,),
                    Text("Image Not Available.", style: TextStyle(color: Colors.black54),)
                  ],
                ),
              );
            break;
        }
        return Container();
      }
    );
  }
}
