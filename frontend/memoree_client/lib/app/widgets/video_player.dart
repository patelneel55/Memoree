@JS()
library video_player;

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:sprintf/sprintf.dart';

@JS('executeStream')
external void executeStream(dynamic path, dynamic host, dynamic port);

class VideoPlayer extends StatefulWidget {
  final String videoURL;

  VideoPlayer(this.videoURL);
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: EasyWebView(
        src: sprintf(videoPlayerContent, [widget.videoURL, "localhost", "8024"]) ,
        onLoaded: () {
          if(!_isLoaded)
          {
            _isLoaded = true;
            // executeStream(widget.videoURL, "localhost", 8024);\
          }
        },
        isHtml: true,
        isMarkdown: false,
      ),
    );
  }

  String get videoPlayerContent => """
  <!DOCTYPE html>
  <html>
      <head>
          <style>
              html, body {
                  padding: 0;
                  margin: 0;
              }
              html {
                  height: 100%;
              }
              body {
                  min-height: 100%;
                  display: flex;
                  flex-direction: column;
                  justify-content: center;
                  align-items: center;
                  align-content: center;
              }
          </style>

          <!-- Video.js Player -->
          <link href="https://vjs.zencdn.net/7.10.2/video-js.css" rel="stylesheet"/>
          <link href="https://unpkg.com/@videojs/themes@1/dist/forest/index.css" rel="stylesheet"/>
          <script src="https://vjs.zencdn.net/7.10.2/video.min.js"></script>

          <!-- JQuery -->
          <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
      </head>
      <body>
          <div id="player_container">
              <video id="video" class="video-js vjs-theme-forest" preload="auto" height="60%" disablePictureInPicture controls></video>
          </div>

          <script>
            let videoPath = "%s";
            let streamServer = "%s";
            let streamPort = "%s";
            let path = encodeURIComponent(videoPath);

            var video = videojs("video");
            video.src({
                src: "http://"+ streamServer + ":" + streamPort + "/media/" + path,
                type: 'video/mp4'
            });

            // Get the dureation of the movie
            \$.getJSON("http://"+ streamServer + ":" + streamPort + "/duration/" + path, (data) => {
                video.theDuration = data.duration / 1000;
            });

            // hack duration
            video.duration = () => video.theDuration;
            video.start = 0;

            // The original code for "currentTime"
            video.oldCurrentTime = function currentTime(seconds) {
              if (typeof seconds !== 'undefined') {
                if (seconds < 0)
                  seconds = 0;

                this.techCall_('setCurrentTime', seconds);
                return;
              }
              this.cache_.currentTime = this.techGet_('currentTime') || 0;
              return this.cache_.currentTime;
            }

            // Our modified currentTime
            video.currentTime = (time) => {
              if( time == undefined )
                return video.oldCurrentTime() + video.start;

              video.start = time;
              video.oldCurrentTime(0);
              video.src({
                src: "http://" + streamServer + ":" + streamPort + "/media/" + path + "?start=" + time,
                type: 'video/mp4'
              });
              video.play();
              return this;
            };
          </script>
      </body>
  </html>
  """;
}
