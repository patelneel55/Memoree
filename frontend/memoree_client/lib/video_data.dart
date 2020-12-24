import 'package:cloud_functions/cloud_functions.dart';

class VideoData {
  final String filename;
  final String videoUrl;
  final DateTime timestamp;
  final List<dynamic> data;

  VideoData({this.filename, this.videoUrl, this.timestamp, this.data});

  factory VideoData.fromJson(Map<String, dynamic> json) {

    return VideoData(
      filename: json['file_name'],
      videoUrl: json['videoURL'],
      timestamp: json['timestamp'],
      data: json['document']
    );
  }
}

Future<List<VideoData>> fetchSearchResults(String query, {int page : 1}) async {
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