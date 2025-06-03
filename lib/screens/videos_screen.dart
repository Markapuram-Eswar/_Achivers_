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
  int correctFlagIndex = 0; // index of correct button (door)
  int correctSelections = 0;
  int wrongOrTimeoutCount = 0;
  final int maxCorrectSelections = 3;
  final int maxWrongOrTimeouts = 3;
  Timer? _buttonTimer;
  bool _terminated = false;
  int grade = 1;
  int sec = 20;

  @override
  void initState() {
    super.initState();
    if (grade <= 3) {
      _playVideo('assets/intro1.mp4', onEnd: () {
        _playVideo('assets/12.mp4', onEnd: _showButtonPage);
      });
    } else if (grade > 3 && grade < 7) {
      _playVideo('assets/intro2.mp4', onEnd: () {
        _playVideo('assets/22.mp4', onEnd: _showButtonPage);
      });
    } else {
      _playVideo('assets/intro3.mp4', onEnd: () {
        _playVideo('assets/32.mp4', onEnd: _showButtonPage);
      });
    }
  }

  void _playVideo(String path, {required VoidCallback onEnd}) async {
    _disposeController();
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

    _buttonTimer = Timer(Duration(seconds: sec), () {
      Navigator.of(context).pop();
      _handleTimeout();
    });
    if (grade < 3) {
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
    } else if (grade > 3 && grade < 7) {
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
    } else {
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
  }

  void _handleButtonSelection(int index) {
    if (_terminated) return;
    if (grade < 3) {
      _playVideo('assets/1${index + 3}.mp4', onEnd: () {
        if (index == correctFlagIndex) {
          correctSelections++;
          if (correctSelections >= maxCorrectSelections) {
            _terminated = true;
            _playVideo('assets/19.mp4', onEnd: () {});
          } else {
            _playVideo('assets/12.mp4', onEnd: _showButtonPage);
          }
        } else {
          wrongOrTimeoutCount++;
          if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
            _terminated = true;
            // Terminate immediately without playing video9
          } else {
            _playVideo('assets/18.mp4', onEnd: () {
              _playVideo('assets/12.mp4', onEnd: _showButtonPage);
            });
          }
        }
      });
    } else if (grade > 3 && grade < 7) {
      _playVideo('assets/3,4,5,6.mp4', onEnd: () {
        if (index == correctFlagIndex) {
          correctSelections++;
          if (correctSelections >= maxCorrectSelections) {
            _terminated = true;
            _playVideo('assets/29.mp4', onEnd: () {});
          } else {
            _playVideo('assets/22.mp4', onEnd: _showButtonPage);
          }
        } else {
          wrongOrTimeoutCount++;
          if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
            _terminated = true;
            // Terminate immediately without playing video9
          } else {
            _playVideo('assets/28.mp4', onEnd: () {
              _playVideo('assets/22.mp4', onEnd: _showButtonPage);
            });
          }
        }
      });
    } else {
      _playVideo('assets/3${index + 3}.mp4', onEnd: () {
        if (index == correctFlagIndex) {
          correctSelections++;
          if (correctSelections >= maxCorrectSelections) {
            _terminated = true;
            _playVideo('assets/39.mp4', onEnd: () {});
          } else {
            _playVideo('assets/32.mp4', onEnd: _showButtonPage);
          }
        } else {
          wrongOrTimeoutCount++;
          if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
            _terminated = true;
            // Terminate immediately without playing video9
          } else {
            _playVideo('assets/38.mp4', onEnd: () {
              _playVideo('assets/32.mp4', onEnd: _showButtonPage);
            });
          }
        }
      });
    }
  }

  void _handleTimeout() {
    if (_terminated) return;

    wrongOrTimeoutCount++;
    if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
      _terminated = true;
      // Terminate immediately without playing video9
    } else {
      if (grade < 3) {
        _playVideo('assets/17.mp4', onEnd: () {
          _playVideo('assets/12.mp4', onEnd: _showButtonPage);
        });
      } else if (grade > 3 && grade < 7) {
        _playVideo('assets/27.mp4', onEnd: () {
          _playVideo('assets/22.mp4', onEnd: _showButtonPage);
        });
      } else {
        _playVideo('assets/37.mp4', onEnd: () {
          _playVideo('assets/32.mp4', onEnd: _showButtonPage);
        });
      }
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
