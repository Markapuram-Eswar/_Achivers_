import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

void main() => runApp(const VideoSequenceApp());

class VideoSequenceApp extends StatelessWidget {
  const VideoSequenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Flow App',
      theme: ThemeData.dark(),
      home: const VideoFlowScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoFlowScreen extends StatefulWidget {
  const VideoFlowScreen({super.key});

  @override
  VideoFlowScreenState createState() => VideoFlowScreenState();
}

class VideoFlowScreenState extends State<VideoFlowScreen> {
  VideoPlayerController? _controller;
  int correctFlagIndex = 0; // index of correct button (door)
  int correctSelections = 0;
  int wrongOrTimeoutCount = 0;
  final int maxCorrectSelections = 3;
  final int maxWrongOrTimeouts = 3;
  Timer? _buttonTimer;
  bool _terminated = false;

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch videos list from backend (API call, database read) */
    _playVideo('assets/videos/park_theme.mp4', onEnd: () {
      _playVideo('assets/videos/park_theme.mp4', onEnd: _showButtonPage);
    });
  }

  void _playVideo(String path, {required VoidCallback onEnd}) async {
    _disposeController();
    // Add a short delay before initializing the new controller
    await Future.delayed(const Duration(milliseconds: 200));
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

    _buttonTimer = Timer(const Duration(seconds: 10), () {
      Navigator.of(context).pop();
      _handleTimeout();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Choose a Door'),
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

    _playVideo('assets/video${index + 3}.mp4', onEnd: () {
      if (index == correctFlagIndex) {
        correctSelections++;
        if (correctSelections >= maxCorrectSelections) {
          _terminated = true;
          _playVideo('assets/videos/park_theme.mp4', onEnd: () {});
        } else {
          _playVideo('assets/videos/park_theme.mp4', onEnd: _showButtonPage);
        }
      } else {
        wrongOrTimeoutCount++;
        if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
          _terminated = true;
          // Terminate immediately without playing video9
        } else {
          _playVideo('assets/videos/park_theme.mp4', onEnd: () {
            _playVideo('assets/videos/park_theme.mp4', onEnd: _showButtonPage);
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
      // Terminate immediately without playing video9
    } else {
      _playVideo('assets/videos/park_theme.mp4', onEnd: () {
        _playVideo('assets/videos/park_theme.mp4', onEnd: _showButtonPage);
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
      appBar: AppBar(title: const Text('Video Flow')),
      body: Center(
        child: _controller != null && _controller!.value.isInitialized
            ? Container(
                margin: const EdgeInsets.all(12),
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
            : const CircularProgressIndicator(),
      ),
    );
  }
}
