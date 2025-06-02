import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(
      MaterialApp(
        home: TextbookPage(
          subjectId: 'science101',
          topicId: 'biology-basics',
        ),
      ),
    );

class TextbookPage extends StatefulWidget {
  final String subjectId;
  final String topicId;

  const TextbookPage({
    super.key,
    required this.subjectId,
    required this.topicId,
  });

  @override
  State<TextbookPage> createState() => _TextbookPageState();
}

class _TextbookPageState extends State<TextbookPage> {
  late Future<Map<String, dynamic>> _textbookData;
  final FlutterTts _flutterTts = FlutterTts();
  List<dynamic> _voices = [];
  String? _selectedVoice;
  int? _currentlySpeakingIndex;

  @override
  void initState() {
    super.initState();
    _textbookData = fetchTextbookData(widget.subjectId, widget.topicId);
    _initTts();
  }

  Future<void> _initTts() async {
    _voices = await _flutterTts.getVoices;

    // Optional: Filter and pick only first 4 English voices for demo
    _voices = _voices
        .where((v) => v['locale'].toString().startsWith('en'))
        .take(4)
        .toList();

    if (_voices.isNotEmpty) {
      _selectedVoice = _voices[0]['name'];
      await _flutterTts.setVoice(_voices[0]);
    }

    setState(() {});

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _currentlySpeakingIndex = null;
      });
    });
  }

  Future<Map<String, dynamic>> fetchTextbookData(
      String subjectId, String topicId) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "subjectData": {
        "id": subjectId,
        "name": "Science",
        "color": const Color(0xFF2196F3),
      },
      "topicData": {
        "id": topicId,
        "title": "Biology Basics",
        "icon": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
        "content": [
          {
            "heading": "Introduction to Biology",
            "paragraph":
                "Biology is the study of living organisms, divided into many specialized fields...",
            "image":
                "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Cell_diagram.svg/1200px-Cell_diagram.svg.png"
          },
          {
            "heading": "Cell Structure",
            "paragraph":
                "Cells are the basic building blocks of all living things. They can be prokaryotic or eukaryotic..."
          },
          {
            "heading": "Photosynthesis",
            "paragraph":
                "Photosynthesis is the process by which green plants and some other organisms use sunlight to synthesize foods...",
            "image":
                "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Photosynthesis.svg/1280px-Photosynthesis.svg.png"
          }
        ]
      }
    };
  }

  Future<void> _speak(String text, int index) async {
    if (_currentlySpeakingIndex == index) {
      await _flutterTts.stop();
      setState(() {
        _currentlySpeakingIndex = null;
      });
    } else {
      await _flutterTts
          .setVoice(_voices.firstWhere((v) => v['name'] == _selectedVoice));
      await _flutterTts.speak(text);
      setState(() {
        _currentlySpeakingIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _textbookData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        } else {
          final subjectData = snapshot.data!['subjectData'];
          final topicData = snapshot.data!['topicData'];
          final List<dynamic> content = topicData['content'];

          return Scaffold(
            appBar: AppBar(
              title: Text(
                topicData['title'],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: subjectData['color'],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              subjectData['color'].withOpacity(0.2),
                          child: Image.network(
                            topicData['icon'],
                            width: 30,
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            topicData['title'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_voices.isNotEmpty) ...[
                      const Text("Select Voice:"),
                      DropdownButton<String>(
                        value: _selectedVoice,
                        items: _voices
                            .map<DropdownMenuItem<String>>(
                                (voice) => DropdownMenuItem<String>(
                                      value: voice['name'],
                                      child: Text(voice['name']),
                                    ))
                            .toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedVoice = value;
                          });
                          await _flutterTts.setVoice(
                              _voices.firstWhere((v) => v['name'] == value));
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    ...List.generate(content.length, (index) {
                      final section = content[index];
                      final isSpeaking = _currentlySpeakingIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section['heading'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: isSpeaking
                                    ? Colors.yellow.withOpacity(0.2)
                                    : null,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      section['paragraph'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isSpeaking ? Icons.stop : Icons.volume_up,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _speak(section['paragraph'], index),
                                  ),
                                ],
                              ),
                            ),
                            if (section.containsKey('image'))
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Image.network(
                                  section['image'],
                                  height: 150,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
