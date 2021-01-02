import 'package:flutter/material.dart';

import 'package:memoree_client/app/widgets/video_card.dart';

class ContentGrid extends StatefulWidget {
  @override
  _ContentGridState createState() => _ContentGridState();
}

class _ContentGridState extends State<ContentGrid> {
  @override
  Widget build(BuildContext context) {

    return GridView.builder(
      itemCount: 40,
      padding: const EdgeInsets.all(20.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300.0,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 10.0,
        // childAspectRatio: 1.15,
      ),
      itemBuilder: (BuildContext context, int index) {
        return VideoCard(null);
      },
    );
  }
}