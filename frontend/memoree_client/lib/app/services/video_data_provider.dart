import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/video_data.dart';

class VideoDataProvider extends InheritedWidget {
  final VideoData videoData;

  VideoDataProvider({
    @required Widget child,
    @required this.videoData
  }) : super(child: child);

  @override
  bool updateShouldNotify(VideoDataProvider oldWidget) => this.videoData != oldWidget.videoData;

  static VideoDataProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<VideoDataProvider>();
}
