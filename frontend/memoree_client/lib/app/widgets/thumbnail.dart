import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memoree_client/app/models/video_data.dart';

class ThumbnailGenerator extends StatelessWidget {
  final VideoData videoData;
  final bool dryrun;

  ThumbnailGenerator({this.videoData, this.dryrun});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: dryrun ? Future.delayed(Duration(seconds: 3)) : videoData.getThumbnail(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return dryrun ? 
              Image.network('https://picsum.photos/250?image=9', fit: BoxFit.cover,) : 
              Image.file(File(snapshot.data), fit: BoxFit.cover);
            break;
        }
        return Container();
      }
    );
  }
}
