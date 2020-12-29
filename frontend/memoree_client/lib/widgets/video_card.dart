import 'package:flutter/material.dart';
import 'package:memoree_client/thumbnail.dart';
import 'package:memoree_client/video_data.dart';

class VideoCard extends StatelessWidget {
  final VideoData videoData;

  VideoCard(this.videoData);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        // elevation: 1,
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 3 / 2,
              child: ThumbnailGenerator(videoData: this.videoData, dryrun: true)
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Text("Hello World")
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("98%", textAlign: TextAlign.right,)
                  )
                ]
              )
            )
          ],
        )
      ),
    );
  }
}