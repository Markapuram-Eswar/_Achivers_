import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MaterialApp(home: SimpleReadingTracker()));

class SimpleReadingTracker extends StatefulWidget {
  const SimpleReadingTracker({super.key});

  @override
  SimpleReadingTrackerState createState() => SimpleReadingTrackerState();
}

class SimpleReadingTrackerState extends State<SimpleReadingTracker> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  int _currentWordIndex = 0;

  final String paragraph =
      "Flutter is an open-source UI toolkit by Google, Could you please clarify where you want to add more paragraphs? If you're referring to adding more instructional or descriptive paragraphs in your app's UI (e.g., Flutter & Dart), or if you want to add more sample text—like 80% of developers use Flutter—for speech-to-text reading!";
  List<String> _textWords = [];
  List<String> _comparisonWords = [];
  final Set<int> _readIndices = {};
  final Set<int> _skippedIndices = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeText();
    _checkPermissions();
  }

  // Request microphone/audio permission
  Future<bool> requestAudioPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  String _cleanTextForComparison(String text) {
    return text
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll("'", '')
        .replaceAll(',', '')
        .replaceAll('?', '')
        .replaceAll('!', '')
        .replaceAll(';', '')
        .replaceAll(':', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('"', '')
        .replaceAll('—', ' ')
        .replaceAll('–', ' ')
        .replaceAll('…', '')
        .replaceAll('%', '')
        .replaceAll('&', ' and ')
        .replaceAll('/', ' ')
        .replaceAll('*', '')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _cleanTextForDisplay(String text) {
    final words = text.split(' ').where((word) => word.isNotEmpty).toList();
    return words;
  }

  String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  void _initializeText() {
    _textWords = _cleanTextForDisplay(paragraph);
    _comparisonWords = _textWords.map(_cleanTextForComparison).toList();
    _readIndices.clear();
    _skippedIndices.clear();
    _currentWordIndex = 0;
  }

  void _startListening() async {
    if (await Permission.microphone.status != PermissionStatus.granted) {
      await _checkPermissions();
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' && _isListening && mounted) {
          _startListening();
        }
      },
      onError: (val) {
        debugPrint('Speech error: $val');
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech error: $val')),
          );
        }
      },
    );

    if (available && mounted) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (!mounted) return;
          final rawSpokenText = val.recognizedWords;
          final spokenText = _cleanTextForComparison(rawSpokenText);
          debugPrint('Raw spoken: "$rawSpokenText"');
          debugPrint('Cleaned spoken: "$spokenText"');

          if (_currentWordIndex >= _comparisonWords.length) return;
          final expected = _comparisonWords[_currentWordIndex];
          debugPrint('Expected (cleaned): "$expected"');

          if (spokenText.contains(expected)) {
            setState(() {
              _readIndices.add(_currentWordIndex);
              _currentWordIndex++;
            });
          }
          // Removed SnackBar for expected word feedback
        },
      );
    } else if (mounted) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to initialize speech recognition')),
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _skipCurrentWord() {
    if (_currentWordIndex < _textWords.length) {
      setState(() {
        _skippedIndices.add(_currentWordIndex);
        _currentWordIndex++;
      });
    }
  }

  void _reset() {
    _stopListening();
    setState(() => _initializeText());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reading Tracker',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black54,
      ),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: _isListening ? Colors.red[600] : Colors.green[600],
        tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LinearProgressIndicator(
              value: _textWords.isEmpty
                  ? 0
                  : (_readIndices.length + _skippedIndices.length) /
                      _textWords.length,
              backgroundColor: Colors.grey[300],
              color: Colors.brown[600],
              minHeight: 6,
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 10,
                    children: _textWords.asMap().entries.map((entry) {
                      final index = entry.key;
                      final word = entry.value;
                      final isCurrent = index == _currentWordIndex;
                      final color = _skippedIndices.contains(index)
                          ? Colors.red[600]!
                          : _readIndices.contains(index)
                              ? Colors.green[600]!
                              : isCurrent
                                  ? Colors.blue[600]!
                                  : Colors.black87;

                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isCurrent ? 22 : 18,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'Georgia',
                          color: color,
                          height: 1.6,
                        ),
                        child: Text('${_capitalizeWord(word)} '),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _skipCurrentWord,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip Word'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopListening();
    _speech.cancel();
    super.dispose();
  }
}
