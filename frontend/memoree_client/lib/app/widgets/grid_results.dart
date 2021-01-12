import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/video_data.dart';
import 'package:memoree_client/app/services/video_data_provider.dart';
import 'package:memoree_client/app/widgets/video_card.dart';

class ContentGrid extends StatefulWidget {
  final List<VideoData> videoDataList;

  ContentGrid({this.videoDataList});
  @override
  _ContentGridState createState() => _ContentGridState();
}

class _ContentGridState extends State<ContentGrid> {
  @override
  Widget build(BuildContext context) {

    return GridView.builder(
      itemCount: widget.videoDataList != null ? widget.videoDataList.length : 0,
      padding: const EdgeInsets.all(20.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
        crossAxisSpacing: 20.0,
        // mainAxisSpacing: 10.0,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return VideoDataProvider(
          child: VideoCard(),
          videoData: widget.videoDataList[index]
        );
      },
    );
  }
}