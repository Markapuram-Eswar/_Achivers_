import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  bool _isListening = false;
  String _transcribedText = '';
  int _score = 0;
  int _questionIndex = 0;
  String _feedback = '';
  bool _quizCompleted = false;
  String _userNotes = '';
  bool _isInitialized = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Name five European countries.',
      'keywords': ['france', 'germany', 'italy', 'spain', 'sweden'],
      'maxScore': 5,
      'hint': 'Think about major countries in Western Europe',
    },
    {
      'question': 'Name three more European countries.',
      'keywords': ['portugal', 'netherlands', 'belgium'],
      'maxScore': 3,
      'hint': 'Consider countries in the Benelux region',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _initializeSpeech();
    await _initializeTts();
    setState(() => _isInitialized = true);
    _speakQuestion();
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) =>
            setState(() => _isListening = status == 'listening'),
        onError: (error) => _showError('Speech Error: $error'),
      );
      if (!available) {
        _showError('Speech recognition not available');
      }
    } catch (e) {
      _showError('Error initializing speech: $e');
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
    } catch (e) {
      _showError('Error initializing TTS: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _speakQuestion() async {
    if (_questionIndex < _questions.length) {
      await _tts.speak(_questions[_questionIndex]['question']);
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      _evaluateAnswer();
    } else {
      setState(() {
        _transcribedText = '';
        _feedback = '';
      });
      _speech.listen(
        onResult: (result) =>
            setState(() => _transcribedText = result.recognizedWords),
      );
    }
  }

  void _evaluateAnswer() {
    if (_transcribedText.isEmpty) {
      setState(() => _feedback = 'No answer provided.');
      return;
    }

    final keywords = _questions[_questionIndex]['keywords'] as List<String>;
    final maxScore = _questions[_questionIndex]['maxScore'] as int;
    int matches = 0;
    String lowercaseText = _transcribedText.toLowerCase();

    for (String keyword in keywords) {
      if (lowercaseText.contains(keyword)) matches++;
    }

    setState(() {
      _score += matches;
      _feedback = 'You got $matches out of $maxScore correct!';
      if (matches >= maxScore * 0.8) _confettiController.play();
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _questionIndex++;
        if (_questionIndex < _questions.length) {
          _speakQuestion();
        } else {
          _quizCompleted = true;
          _tts.speak('Quiz completed! Your final score is $_score.');
          _confettiController.play();
        }
      });
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[700]!,
              Colors.purple[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _quizCompleted ? _buildScoreboard() : _buildQuiz(),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.05,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.yellow,
                    Colors.purple,
                    Colors.orange,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Voice Quiz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHint(),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    if (_questionIndex >= _questions.length) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hint'),
        content: Text(_questions[_questionIndex]['hint'] as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildQuestionCard(),
          const SizedBox(height: 24),
          _buildMicButton(),
          const SizedBox(height: 24),
          _buildTranscriptionCard(),
          const SizedBox(height: 24),
          _buildFeedbackCard(),
          const SizedBox(height: 24),
          _buildNotesCard(),
        ].animate(interval: 200.ms).fadeIn().slideY(),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Question ${_questionIndex + 1}',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _questions[_questionIndex]['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? Colors.red : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: 50,
          color: _isListening ? Colors.white : Colors.blue[700],
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
    );
  }

  Widget _buildTranscriptionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your Answer',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _transcribedText.isEmpty
                  ? 'Speak your answer...'
                  : _transcribedText,
              style: TextStyle(
                fontSize: 16,
                color: _transcribedText.isEmpty ? Colors.grey : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    if (_feedback.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          _feedback,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Add Notes',
            labelStyle: TextStyle(color: Colors.blue[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
          ),
          maxLines: 3,
          onChanged: (value) => setState(() => _userNotes = value),
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Quiz Completed! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Your Score',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_userNotes.isNotEmpty) ...[
                const Text(
                  'Your Notes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _userNotes,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _questionIndex = 0;
                    _score = 0;
                    _quizCompleted = false;
                    _feedback = '';
                    _transcribedText = '';
                    _userNotes = '';
                  });
                  _speakQuestion();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale().fadeIn(),
    );
  }
}
