import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatelessWidget {
  final String url;

  MyVideoPlayer({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: MyVideoPlayerScreen(url: url),
    );
  }
}

class MyVideoPlayerScreen extends StatefulWidget {
  final String url;

  MyVideoPlayerScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => MyVideoPlayerScreenState(url: url);
}

class MyVideoPlayerScreenState extends State<MyVideoPlayerScreen> {
  final String url;
  bool isPlaying = false;
  VideoPlayerController _controller;
  MyVideoPlayerScreenState({Key key, @required this.url});
  playVideo() {
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void initState() {
    playVideo();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    if (!isPlaying) {
                      _controller.play();
                      setState(() {
                        isPlaying = true;
                      });
                    } else {
                      _controller.pause();
                      setState(() {
                        isPlaying = false;
                      });
                    }
                  },
                  child: VideoPlayer(_controller)),
              Center(
                child: Material(
                  borderOnForeground: false,
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      if (!isPlaying) {
                        _controller.play();
                        setState(() {
                          isPlaying = true;
                        });
                      } else {
                        _controller.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      }
                    },
                    icon: isPlaying
                        ? Container()
                        : Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: Colors.grey[500],
                          ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
