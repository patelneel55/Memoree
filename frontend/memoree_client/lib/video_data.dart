import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoData {
  final String filename;
  final String videoUrl;
  final DateTime timestamp;
  final List<dynamic> data;
  String thumbnailPath;

  VideoData({this.filename, this.videoUrl, int timestamp, this.data}) : this.timestamp = timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null, this.thumbnailPath = "";

  factory VideoData.fromJson(Map<String, dynamic> json) {

    return VideoData(
      filename: json['file_name'],
      videoUrl: json['videoURL'],
      timestamp: json['timestamp'],
      data: json['document']
    );
  }

  Future<String> getThumbnail() async
  {
    if(this.thumbnailPath.isNotEmpty)
      return this.thumbnailPath;
    
    final HttpsCallable funcCallable = FirebaseFunctions.instance.httpsCallable("generate_thumbnail");

    try {
      final HttpsCallableResult result = await funcCallable.call(<String, dynamic>{'video_url': this.videoUrl});
      File thumb = File.fromRawPath(base64Decode(result.data));

      String filePath = "";
      do {
        String fileName = String.fromCharCodes(List.generate(7, (index) => Random.secure().nextInt(33) + 89)) + ".png";
        filePath = path.join((await getApplicationDocumentsDirectory()).path, fileName);
      } while(await File(filePath).exists());

      thumb.copySync(filePath);
      this.thumbnailPath = filePath;
      return this.thumbnailPath;
    }
    catch(err)
    {
      print(err);
      return null;
    }
  }
}

Future<List<VideoData>> fetchSearchResults(String query, {int page : 1}) async
{
  final HttpsCallable funcCallable = FirebaseFunctions.instance.httpsCallable("search");

  try {
    final HttpsCallableResult result = await funcCallable.call(<String, dynamic>{'q': query, 'page': page});
    return result.data.map<VideoData>((obj) {
      return VideoData.fromJson(obj);
    }).toList();
  }
  catch(err) {
    print(err);
    return null;
  }
}