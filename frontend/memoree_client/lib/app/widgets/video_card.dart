import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoree_client/app/models/video_data.dart';
import 'package:memoree_client/app/services/video_data_provider.dart';

import 'package:memoree_client/app/widgets/thumbnail.dart';
import 'package:memoree_client/app/pages/player.dart';

class VideoCard extends StatefulWidget {

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isHovering;
  ScrollController _scrollController = ScrollController();
  bool _isScrolling;
  Widget _thumbnailWidget; 

  @override
  void initState() {
    super.initState();
    _isHovering = false;
    _isScrolling = false;
    _thumbnailWidget = null;
  }

  void _updateHoverStatus(bool status) {
    setState(() {
      _isHovering = status;
    });
  }

  void _updateScrollingStatus() {
    setState(() {
      _isScrolling = !_isScrolling;
    });

    if(_isScrolling)
    {
      double maxExtent = _scrollController.position.maxScrollExtent;
      double distanceDifference = maxExtent - _scrollController.offset;
      double durationDouble = distanceDifference / 30;

      _scrollController.animateTo(
        maxExtent,
        duration: Duration(seconds: durationDouble.toInt()),
        curve: Curves.linear
      );
    }
    else
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 10),
        curve: Curves.linear
      );
  }

  @override
  Widget build(BuildContext context) {
    final VideoData _videoData = VideoDataProvider.of(context).videoData;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            // elevation: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: _thumbnailWidget ??= ThumbnailGenerator(videoData: _videoData, dryrun: false)
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_videoData.filename),
                            SizedBox(height: 5),
                            Stack(
                              children: <Widget>[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _scrollController,
                                  child: Text(
                                      _videoData.filePath,
                                      textScaleFactor: 0.9,
                                      style: TextStyle(color: Colors.black54),
                                    )
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        stops: [0, 0.065],
                                        colors: [
                                          Theme.of(context).scaffoldBackgroundColor,
                                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          NumberFormat("###.#%").format(_videoData.data["confidence"]),
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        )
                      )
                    ]
                  )
                )
              ],
            )
          ),
        ),
        Positioned(
          child: AnimatedOpacity(
            opacity: _isHovering ? 1.0 : 0.0,
            duration: Duration(milliseconds: 100),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Center(
                child: const Icon(Icons.play_arrow, size: 100)
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onHover: (isHovering) {
                _updateHoverStatus(isHovering);
                _updateScrollingStatus();
              },
              onTap: () {
                print(_videoData.videoUrl);
                showDialog(
                  barrierColor: Colors.black87,
                  context: context,
                  builder: (_) => PlayerPage(_videoData),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}