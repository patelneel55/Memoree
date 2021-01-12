import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/video_data.dart';
import 'package:memoree_client/app/widgets/video_player.dart';

class PlayerPage extends StatelessWidget {
  final VideoData videoData;

  PlayerPage(this.videoData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: VideoPlayer(videoData.videoUrl),
        ),
      ),
    );
  }
}
