import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() => runApp(VideoSequenceApp());

class VideoSequenceApp extends StatelessWidget {
  const VideoSequenceApp({super.key});

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
  const VideoFlowScreen({super.key});

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
  int grade = 9;
  int sec = 10;

  // Quiz related variables
  int _currentQuestionIndex = 0;
  late List<Map<String, dynamic>> _shuffledQuestions;
  late List<List<String>> _shuffledOptions = [];
  late List<int> _correctAnswerIndices = [];

  // List of questions with their options and correct answer index
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'What is the capital of France?',
      'options': ['Paris', 'London', 'Berlin', 'Madrid'],
      'correctIndex': 0,
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'correctIndex': 1,
    },
    {
      'question': 'What is the largest mammal in the world?',
      'options': ['African Elephant', 'Blue Whale', 'Giraffe', 'Polar Bear'],
      'correctIndex': 1,
    },
    {
      'question': 'Which element has the chemical symbol "O"?',
      'options': ['Gold', 'Oxygen', 'Osmium', 'Oganesson'],
      'correctIndex': 1,
    },
  ];

  void _initializeQuiz() {
    _shuffledQuestions = List.from(_quizQuestions);
    _shuffledQuestions.shuffle();

    _shuffledOptions = [];
    _correctAnswerIndices = [];

    for (var question in _shuffledQuestions) {
      final options = List<String>.from(question['options'] as List);
      final correctAnswer = options[question['correctIndex'] as int];

      // Shuffle options
      options.shuffle();

      // Find the new index of the correct answer
      final correctIndex = options.indexOf(correctAnswer);

      _shuffledOptions.add(options);
      _correctAnswerIndices.add(correctIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVideoSequence();
    });
  }

  void _startVideoSequence() {
    if (grade <= 3) {
      _playVideo('assets/videos/Intro1.mp4', onEnd: () {
        _playVideo('assets/videos/12.mp4', onEnd: _showButtonPage);
      });
    } else if (grade > 3 && grade < 7) {
      _playVideo('assets/videos/Intro2.mp4', onEnd: () {
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
    // Initialize quiz on first call
    if (_currentQuestionIndex == 0) {
      _initializeQuiz();
    }

    // If we've shown all questions and have correct answers
    if (_currentQuestionIndex >= _shuffledQuestions.length) {
      if (correctSelections >= maxCorrectSelections &&
          wrongOrTimeoutCount < maxWrongOrTimeouts) {
        _terminated = true;
        String successVideo = grade <= 3
            ? 'assets/videos/19.mp4'
            : grade < 7
                ? 'assets/videos/29.mp4'
                : 'assets/videos/39.mp4';
        _playVideo(successVideo, onEnd: _showGameOverDialog);
        return;
      } else {
        _currentQuestionIndex = 0;
        _initializeQuiz();
      }
    }

    int sec = 15; // Increased time for reading questions

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sec > 0) {
        setState(() {
          this.sec = sec--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
          _handleTimeout();
        }
      }
    });

    _buttonTimer = Timer(Duration(seconds: sec), () {
      _countdownTimer?.cancel();
      if (mounted) {
        Navigator.of(context).pop();
        _handleTimeout();
      }
    });

    final currentQuestion = _shuffledQuestions[_currentQuestionIndex];
    final currentOptions = _shuffledOptions[_currentQuestionIndex];
    final correctIndex = _correctAnswerIndices[_currentQuestionIndex];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            'Question ${_currentQuestionIndex + 1} of ${_shuffledQuestions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 450,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion['question'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(currentOptions.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blueGrey[800]?.withOpacity(0.85),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: index == correctIndex
                                      ? Colors.greenAccent.withOpacity(0.5)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () {
                              _buttonTimer?.cancel();
                              _countdownTimer?.cancel();
                              if (mounted) {
                                Navigator.of(context).pop();
                                _currentQuestionIndex++;
                                _handleButtonSelection(index, correctIndex);
                              }
                            },
                            child: Text(
                              currentOptions[index],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleButtonSelection(int selectedIndex, int correctIndex) {
    if (_terminated) return;

    String videoPath;
    String loopVideo;
    String successVideo;
    String failureVideo;

    if (grade <= 3) {
      videoPath = 'assets/videos/1${selectedIndex + 3}.mp4'; // 13, 14, 15, 16
      loopVideo = 'assets/videos/12.mp4';
      successVideo = 'assets/videos/19.mp4';
      failureVideo = 'assets/videos/18.mp4';
    } else if (grade > 3 && grade < 7) {
      videoPath = 'assets/videos/3,4,5,6.mp4'; // Same for all options
      loopVideo = 'assets/videos/22.mp4';
      successVideo = 'assets/videos/29.mp4';
      failureVideo = 'assets/videos/28.mp4';
    } else {
      videoPath = 'assets/videos/3${selectedIndex + 3}.mp4'; // 33, 34, 35, 36
      loopVideo = 'assets/videos/32.mp4';
      successVideo = 'assets/videos/39.mp4';
      failureVideo = 'assets/videos/38.mp4';
    }

    _playVideo(videoPath, onEnd: () {
      if (selectedIndex == correctIndex) {
        correctSelections++;
        if (correctSelections >= maxCorrectSelections &&
            wrongOrTimeoutCount < maxWrongOrTimeouts) {
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
    final bool isWin = correctSelections >= maxCorrectSelections &&
        wrongOrTimeoutCount < maxWrongOrTimeouts;
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
                const Icon(Icons.timer, color: Colors.white, size: 32),
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
