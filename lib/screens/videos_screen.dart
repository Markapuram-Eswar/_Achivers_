import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  VoidCallback? _videoEndListener;
  int correctFlagIndex = 0;
  int correctSelections = 0;
  int wrongOrTimeoutCount = 0;
  final int maxCorrectSelections = 3;
  final int maxWrongOrTimeouts = 3;
  Timer? _buttonTimer;
  Timer? _countdownTimer;
  bool _terminated = false;
  int grade = 1;
  int sec = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVideoSequence();
    });
  }

  void _startVideoSequence() {
    if (grade <= 3) {
      _playVideo('assets/videos/intro1.mp4', onEnd: () {
        _playVideo('assets/videos/12.mp4', onEnd: _showButtonPage);
      });
    } else if (grade > 3 && grade < 7) {
      _playVideo('assets/videos/intro2.mp4', onEnd: () {
        _playVideo('assets/videos/22.mp4', onEnd: _showButtonPage);
      });
    } else {
      _playVideo('assets/videos/intro3.mp4', onEnd: () {
        _playVideo('assets/videos/32.mp4', onEnd: _showButtonPage);
      });
    }
  }

  void _playVideo(String path, {required VoidCallback onEnd}) async {
    _disposeController();

    _controller = kIsWeb
        ? VideoPlayerController.network(path)
        : VideoPlayerController.asset(path);

    await _controller!.initialize();
    setState(() {});
    _controller!.play();

    _videoEndListener = () {
      if (_controller!.value.position >= _controller!.value.duration &&
          !_controller!.value.isPlaying) {
        _controller!.removeListener(_videoEndListener!);
        onEnd();
      }
    };

    _controller!.addListener(_videoEndListener!);
  }

  void _showButtonPage() {
    if (_terminated) return;

    sec = 10; // Reset timer each time dialog is shown

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sec > 0) {
        setState(() {
          sec--;
        });
      } else {
        timer.cancel();
      }
    });

    _buttonTimer = Timer(Duration(seconds: sec), () {
      _countdownTimer?.cancel();
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
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 340,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blueGrey[800]?.withOpacity(0.85),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            _buttonTimer?.cancel();
                            _countdownTimer?.cancel();
                            Navigator.of(context).pop();
                            _handleButtonSelection(index);
                          },
                          child: Text('Door ${index + 1}'),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleButtonSelection(int index) {
    if (_terminated) return;

    String videoPath;
    String loopVideo;
    String successVideo;
    String failureVideo;
    String timeoutVideo;

    if (grade <= 3) {
      videoPath = 'assets/videos/1${index + 3}.mp4';
      loopVideo = 'assets/videos/12.mp4';
      successVideo = 'assets/videos/19.mp4';
      failureVideo = 'assets/videos/18.mp4';
      timeoutVideo = 'assets/videos/17.mp4';
    } else if (grade > 3 && grade < 7) {
      videoPath = 'assets/videos/3,4,5,6.mp4';
      loopVideo = 'assets/videos/22.mp4';
      successVideo = 'assets/videos/29.mp4';
      failureVideo = 'assets/videos/28.mp4';
      timeoutVideo = 'assets/videos/27.mp4';
    } else {
      videoPath = 'assets/videos/3${index + 3}.mp4';
      loopVideo = 'assets/videos/32.mp4';
      successVideo = 'assets/videos/39.mp4';
      failureVideo = 'assets/videos/38.mp4';
      timeoutVideo = 'assets/videos/37.mp4';
    }

    _playVideo(videoPath, onEnd: () {
      if (index == correctFlagIndex) {
        correctSelections++;
        if (correctSelections >= maxCorrectSelections) {
          _terminated = true;
          _playVideo(successVideo, onEnd: _showGameOverDialog);
        } else {
          _playVideo(loopVideo, onEnd: _showButtonPage);
        }
      } else {
        wrongOrTimeoutCount++;
        if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
          _terminated = true;
          _playVideo(failureVideo, onEnd: _showGameOverDialog);
        } else {
          _playVideo(failureVideo, onEnd: () {
            _playVideo(loopVideo, onEnd: _showButtonPage);
          });
        }
      }
    });
  }

  void _handleTimeout() {
    if (_terminated) return;

    wrongOrTimeoutCount++;

    String timeoutVideo;
    String loopVideo;

    if (grade <= 3) {
      timeoutVideo = 'assets/videos/17.mp4';
      loopVideo = 'assets/videos/12.mp4';
    } else if (grade > 3 && grade < 7) {
      timeoutVideo = 'assets/videos/27.mp4';
      loopVideo = 'assets/videos/22.mp4';
    } else {
      timeoutVideo = 'assets/videos/37.mp4';
      loopVideo = 'assets/videos/32.mp4';
    }

    if (wrongOrTimeoutCount >= maxWrongOrTimeouts) {
      _terminated = true;
      _playVideo(timeoutVideo, onEnd: _showGameOverDialog);
      return;
    }

    _playVideo(timeoutVideo, onEnd: () {
      if (!_terminated) {
        _playVideo(loopVideo, onEnd: _showButtonPage);
      }
    });
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _videoEndListener = null;
  }

  void _showGameOverDialog() {
    final bool isWin = correctSelections >= maxCorrectSelections;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(
              isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: isWin ? Colors.amber : Colors.redAccent,
              size: 36,
            ),
            const SizedBox(width: 12),
            Text(
              'Game Over',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isWin ? Colors.amber : Colors.redAccent,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWin
                  ? '🎉 Congratulations! You won the game!'
                  : '😔 Better luck next time!',
              style: TextStyle(
                fontSize: 20,
                color: isWin ? Colors.greenAccent : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              'Question: ${correctSelections + wrongOrTimeoutCount}\nMistakes: $wrongOrTimeoutCount',
              style: const TextStyle(fontSize: 16, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            label:
                const Text('Exit', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeController();
    _buttonTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video player
          Center(
            child: _controller != null && _controller!.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
          // Lives and Timer overlay
          Positioned(
            top: 40,
            left: 24,
            child: Row(
              children: [
                // Life icons
                for (int i = 0;
                    i < maxWrongOrTimeouts - wrongOrTimeoutCount;
                    i++)
                  const Icon(Icons.favorite, color: Colors.red, size: 32),
                for (int i = 0; i < wrongOrTimeoutCount; i++)
                  const Icon(Icons.favorite_border,
                      color: Colors.red, size: 32),
                const SizedBox(width: 24),
                // Timer
                Icon(Icons.timer, color: Colors.white, size: 32),
                const SizedBox(width: 6),
                Text(
                  sec.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Question indicator
                Text(
                  'Question: ${correctSelections + wrongOrTimeoutCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
