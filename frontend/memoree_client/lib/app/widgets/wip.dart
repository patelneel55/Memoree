import 'package:flutter/material.dart';

class WIP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handyman,
              size: 100
            ),
            SizedBox(
              height: 15,
            ),
            Text("Construction in progress. Please come back later."),
          ],
        ),
      ),
    );
  }
}