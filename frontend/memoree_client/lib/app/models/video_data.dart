import 'package:flutter/material.dart';

import 'package:memoree_client/app/services/search.dart';

class VideoData {
  final String filename;
  final String filePath;
  final String videoUrl;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  Image thumbnail;

  VideoData({this.filename, this.filePath, this.videoUrl, int timestamp, this.data}) 
    : this.timestamp = timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp)
    : null, this.thumbnail = null;

  factory VideoData.fromJson(Map<String, dynamic> json) {

    List<String> fileComponents = json['file_name'].split('/');

    return VideoData(
      filename: fileComponents.removeLast(),
      filePath: fileComponents.join('/'),
      videoUrl: json['videoURL'],
      timestamp: json['timestamp'],
      data: json['document']
    );
  }

  Future<Image> getThumbnail() async  
  {
    this.thumbnail ??= await SearchService.fetchThumbnail(this.videoUrl);
    return this.thumbnail;
  }
}
