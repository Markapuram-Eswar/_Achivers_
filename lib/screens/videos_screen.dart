import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

void main() => runApp(VideoSequenceApp());

class VideoSequenceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Flow App',
      theme: ThemeData.dark(),
      home: VideoFlowScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoFlowScreen extends StatefulWidget {
  @override
  _VideoFlowScreenState createState() => _VideoFlowScreenState();
}

class _VideoFlowScreenState extends State<VideoFlowScreen> {
  VideoPlayerController? _controller;
  int correctFlagIndex = 0;
  int correctSelections = 0;
  int wrongOrTimeoutCount = 0;
  final int maxCorrectSelections = 3;
  final int maxWrongOrTimeouts = 3;
  Timer? _buttonTimer;
  bool _terminated = false;

  @override
  void initState() {
    super.initState();
    _playVideo('assets/videos/intro.mp4', onEnd: () {
      _playVideo('assets/videos/2.mp4', onEnd: _showButtonPage);
    });
  }

  void _playVideo(String path, {required VoidCallback onEnd}) async {
    _disposeController();
    await Future.delayed(Duration(milliseconds: 200));
    _controller = VideoPlayerController.asset(path)
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
        _controller!.addListener(() {
          if (_controller!.value.position >= _controller!.value.duration &&
              !_controller!.value.isPlaying) {
            _controller!.removeListener(() {});
            onEnd();
          }
        });
      });
  }

  void _showButtonPage() {
    if (_terminated) return;

    _buttonTimer = Timer(Duration(seconds: 10), () {
      Navigator.of(context).pop();
      _handleTimeout();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text('Choose a Door'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ElevatedButton(
                  onPressed: () {
                    _buttonTimer?.cancel();
                    Navigator.of(context).pop();
                    _handleButtonSelection(index);
                  },
                  child: Text('Door ${index + 1}'),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void _handleButtonSelection(int index) {
    if (_terminated) return;

    // Map door index to specific video (3.mp4 to 6.mp4)
    String selectedVideo = 'assets/videos/${index + 3}.mp4';

    _playVideo(selectedVideo, onEnd: () {
      if (index == correctFlagIndex) {
        correctSelections++;
        if (correctSelections >= maxCorrectSelections) {
          _terminated = true;
          _playVideo('assets/videos/5.mp4', onEnd: () {}); // success video
        } else {
          _playVideo('assets/videos/8.mp4',
              onEnd: _showButtonPage); // next round
        }
      } else {
        wrongOrTimeoutCount++;
        if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
          _terminated = true;
          _playVideo('assets/videos/6.mp4', onEnd: () {}); // failure video
        } else {
          _playVideo('assets/videos/7.mp4', onEnd: () {
            _playVideo('assets/videos/2.mp4',
                onEnd: _showButtonPage); // retry round
          });
        }
      }
    });
  }

  void _handleTimeout() {
    if (_terminated) return;

    wrongOrTimeoutCount++;
    if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
      _terminated = true;
      _playVideo('assets/videos/9.mp4', onEnd: () {}); // timeout end
    } else {
      _playVideo('assets/videos/7.mp4', onEnd: () {
        _playVideo('assets/videos/2.mp4', onEnd: _showButtonPage);
      });
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    _buttonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Flow')),
      body: Center(
        child: _controller != null && _controller!.value.isInitialized
            ? Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
