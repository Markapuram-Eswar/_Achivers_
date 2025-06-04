import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextbookPage extends StatefulWidget {
  final String subjectId;
  final String topicId;

  const TextbookPage({
    Key? key,
    required this.subjectId,
    required this.topicId,
  }) : super(key: key);

  @override
  _TextbookPageState createState() => _TextbookPageState();
}

class _TextbookPageState extends State<TextbookPage> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;
  bool _isSpeaking = false;
  int? _currentlySpeakingIndex;
  
  // Sample data - replace with your actual data source
  final List<Map<String, dynamic>> _content = [
    {
      'heading': 'Introduction to Biology',
      'paragraph': 'Biology is the study of living organisms, divided into many specialized fields...',
    },
    {
      'heading': 'Cell Structure',
      'paragraph': 'Cells are the basic building blocks of all living things...',
    },
    {
      'heading': 'Photosynthesis',
      'paragraph': 'Photosynthesis is the process by which green plants use sunlight to synthesize foods...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Set TTS settings
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      
      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _currentlySpeakingIndex = null;
            _isSpeaking = false;
          });
        }
      });
      
      // Set error handler
      _flutterTts.setErrorHandler((msg) {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('TTS Error: $msg')),
          );
        }
      });
      
      setState(() {
        _isTtsInitialized = true;
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS Initialization Error: $e')),
        );
      }
    }
  }

  Future<void> _speak(String text, int index) async {
    try {
      // If already speaking, stop and reset
      if (_isSpeaking) {
        await _flutterTts.stop();
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingIndex = null;
          });
          // If clicking the same item that's speaking, don't start again
          if (_currentlySpeakingIndex == index) return;
        }
      }

      // Update UI to show which text is being spoken
      if (mounted) {
        setState(() {
          _currentlySpeakingIndex = index;
          _isSpeaking = true;
        });
      }

      // Ensure TTS is initialized
      if (!_isTtsInitialized) {
        await _initTts();
      }

      // Start speaking
      await _flutterTts.speak(text);
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Textbook'),
      ),
      body: ListView.builder(
        itemCount: _content.length,
        itemBuilder: (context, index) {
          final section = _content[index];
          final isSpeaking = _currentlySpeakingIndex == index;
          
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          section['heading'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSpeaking ? Icons.stop : Icons.volume_up,
                          color: isSpeaking ? Colors.red : Colors.blue,
                        ),
                        onPressed: () => _speak(section['paragraph'], index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(section['paragraph']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}