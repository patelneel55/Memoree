import 'dart:math';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'package:memoree_client/app/services/search.dart';
import 'package:memoree_client/app/services/video_data_provider.dart';
import 'package:memoree_client/app/widgets/video_card.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class Carousel extends StatefulWidget {
  final String query;

  Carousel(this.query);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  bool _atStart, _atEnd;
  ScrollController _scrollController;
  ListView _listView;
  AsyncMemoizer _memoizer = AsyncMemoizer();


  @override
  void initState() {
    super.initState();
    _atStart = true;
    _atEnd = false;

    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);

    _listView = null;
  }

  void _scrollListener() {
    if(_scrollController.position.minScrollExtent == _scrollController.position.pixels)
      setState(() {
        _atStart = true;
        _atEnd = false;
      });
    else if(_scrollController.position.maxScrollExtent == _scrollController.position.pixels)
      setState(() {
        _atStart = false;
        _atEnd = true;
      });
    else if(_atStart || _atEnd)
      setState(() {
        _atStart = false;
        _atEnd = false;
      });
  }

  void _moveListRight(bool right) {
    double pixelsToMove = 700;
    double pixelDestination = (right) ?
      _scrollController.offset + min(_scrollController.position.maxScrollExtent - _scrollController.offset, pixelsToMove) :
      _scrollController.offset + -1 * min(_scrollController.offset - _scrollController.position.minScrollExtent, pixelsToMove);
    
    _scrollController.animateTo(
      pixelDestination,
      curve: Curves.linear,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Text(widget.query.capitalize(), textScaleFactor: 1.25, textAlign: TextAlign.left,)
              ) 
            ),
            SizedBox(height: 5.0),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300, minHeight: 200),
              child: FutureBuilder(
                future: _memoizer.runOnce(() async { return SearchService.fetchSearchResults(widget.query, perPage: 10); }),
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: _listView ??= ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data != null ? snapshot.data.length : 0,
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                // _atEnd = _scrollController.position.maxScrollExtent <= 0;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: AspectRatio(
                                    aspectRatio: 1.1,
                                    child: VideoDataProvider(
                                      child: VideoCard(),
                                      videoData: snapshot.data[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if(!_atStart)
                            Positioned(
                              top: 0,
                              left: 0,
                              height: 350,
                              width: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: [0, 0.2],
                                    colors: [
                                      Theme.of(context).scaffoldBackgroundColor,
                                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if(!_atStart)
                            Positioned(
                              top: 0,
                              left: 0,
                              height: 350,
                              child: TextButton(
                                child: Icon(Icons.keyboard_arrow_left, color: Colors.black,size: 36,),
                                onPressed: () {
                                  _moveListRight(false);
                                },
                              ),
                            ),
                          if(!_atEnd)
                            Positioned(
                              top: 0,
                              right: 0,
                              height: 350,
                              width: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    stops: [0, 0.2],
                                    colors: [
                                      Theme.of(context).scaffoldBackgroundColor,
                                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if(!_atEnd)
                            Positioned(
                              top: 0,
                              right: 0,
                              height: 350,
                              child: TextButton(
                                child: Icon(Icons.keyboard_arrow_right, color: Colors.black,size: 36),
                                onPressed: () {
                                  _moveListRight(true);
                                },
                              ),
                            ),
                        ],
                      );
                      break;
                  }
                  return Container();
                }
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
    );
  }
}
