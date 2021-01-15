import 'package:flutter/material.dart';
import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/widgets/carousel.dart';

class LandingPage extends StatelessWidget {
  final List<Carousel> carouselList = PRESET_QUERIES.map<Carousel>((query) => Carousel(query)).toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
                child: Center(
                  child: Text("Common Topics", textScaleFactor: 1.75,),
                ),
              ),
              Divider(),
            ] +
            carouselList +
            [
              SizedBox(height: 50,),
            ],
        ),
      ),
    );
  }
}
