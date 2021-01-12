import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/constants.dart';

class DrawerModel extends ChangeNotifier {
  String _drawerState = PageTitles.videos;

  String get state => this._drawerState;

  void updatePage(query) {
    _drawerState = query;
    notifyListeners();
  }

  void home() {
    _drawerState = PageTitles.videos;
    notifyListeners();
  }
}