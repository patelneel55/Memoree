import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:memoree_client/thumbnail.dart';
import 'package:memoree_client/video_data.dart';

class VideoCard extends StatefulWidget {
  final VideoData videoData;

  VideoCard(this.videoData);

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isHovering;
  ScrollController _scrollController = ScrollController();
  bool _isScrolling;

  @override
  void initState() {
    super.initState();
    _isHovering = false;
    _isScrolling = false;
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
      double durationDouble = distanceDifference / 20;

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
                  child: ThumbnailGenerator(videoData: widget.videoData, dryrun: true)
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
                            Text("Hello World"),
                            SizedBox(height: 5),
                            // ShaderMask(
                            //   shaderCallback: (Rect bounds) {
                            //     return LinearGradient(
                            //       colors: [Colors.white, Colors.white.withOpacity(0.05)],
                            //       stops: [0.7, 1],
                            //       tileMode: TileMode.mirror
                            //     ).createS;
                            //   },
                            //   child: SingleChildScrollView(
                            //     scrollDirection: Axis.horizontal,
                            //     controller: _scrollController,
                            //     child: Text(
                            //         "This is an extremely long text its so long that it is sometimes rendered weirdly",
                            //         textScaleFactor: 0.9,
                            //         style: TextStyle(color: Colors.black54),
                            //       )
                            //   ),
                            // ),
                            Container(
                                  decoration: BoxDecoration(
        color: Colors.white,
          gradient: LinearGradient(
                                  colors: [Colors.white, Colors.white.withOpacity(0.05)],
                                  stops: [0.7, 1],
                                  tileMode: TileMode.mirror
                                )),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: Text(
                                        "This is an extremely long text its so long that it is sometimes rendered weirdly",
                                        textScaleFactor: 0.9,
                                        style: TextStyle(color: Colors.black54),
                                      )
                                  ),
                                ),
                            Flexible(
                              child: Text(
                                "This is an extremely long text its so long that it is sometimes rendered weirdly",
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                textScaleFactor: 0.9,
                                style: TextStyle(color: Colors.black54),
                              ) 
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text("98%", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w500),)
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
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}