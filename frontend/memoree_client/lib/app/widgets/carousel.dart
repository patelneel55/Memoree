import 'dart:math';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _atStart = true;
    _atEnd = false;

    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);

    _listView = ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: 50,
      controller: _scrollController,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: [Colors.red, Colors.green, Colors.yellow][Random().nextInt(3)]
          ),
          height: 100,
          width: 100,
          child: Center(child: Text("$index")),
        );
      },
    );
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text("HELLO WORLD", textAlign: TextAlign.left,)
              ) 
            ),
            Container(
              height: 300,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _listView,
                  ),
                  if(!_atStart)
                    Positioned(
                      top: 0,
                      left: 0,
                      height: 300,
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
                      height: 300,
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
                      height: 300,
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
                      height: 300,
                      child: TextButton(
                        child: Icon(Icons.keyboard_arrow_right, color: Colors.black,size: 36),
                        onPressed: () {
                          _moveListRight(true);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
    );
  }
}
