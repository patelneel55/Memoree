import 'package:flutter/material.dart';

class SearchModel extends ChangeNotifier {
  String _searchQuery;

  String get query => this._searchQuery;

  void updateQuery(query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clear() {
    _searchQuery = null;
    notifyListeners();
  }
}