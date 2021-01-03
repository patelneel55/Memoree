import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:memoree_client/app/models/video_data.dart';

class SearchService {
  
  static Future<List<VideoData>> fetchSearchResults(String query, {int page : 1}) async
  {
    final HttpsCallable funcCallable = FirebaseFunctions.instance.httpsCallable("search");

    try {
      final HttpsCallableResult result = await funcCallable.call(<String, dynamic>{'q': query, 'page': page});
      return result.data.map<VideoData>((obj) {
        return VideoData.fromJson(obj);
      }).toList();
    }
    catch(err) {
      print("fetchSearchResults");
      print(err);
      return null;
    }
  }

  static Future<Image> fetchThumbnail(String videoUrl) async
  {
    final HttpsCallable funcCallable = FirebaseFunctions.instance.httpsCallable("generate_thumbnail");

    try {
      final HttpsCallableResult result = await funcCallable.call(<String, dynamic>{'video_url': videoUrl});
      return Image.memory(base64Decode(result.data));
    }
    catch(err)
    {
      print("fetchThumbnail");
      print(err);
      return null;
    }
  }
}
