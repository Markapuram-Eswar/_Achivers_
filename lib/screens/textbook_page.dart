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
                "Biology is the study of living organisms, divided into many specialized fields...   ",
            "image":
                "https://media.istockphoto.com/id/1322220448/photo/abstract-digital-futuristic-eye.jpg?s=1024x1024&w=is&k=20&c=LEk3Riu7RsJXkWMTEdmQ1yDkgf5F95ScLNZQ4j0P23g="
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
              elevation: 2,
            ),
            body: Container(
              color: const Color(0xFFF5F7FB),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        color: subjectData['color'].withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                child: Image.network(
                                  topicData['icon'],
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topicData['title'],
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      subjectData['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_voices.isNotEmpty) ...[
                        const Text(
                          "Select Voice:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 18),
                      ],
                      ...List.generate(content.length, (index) {
                        final section = content[index];
                        final isSpeaking = _currentlySpeakingIndex == index;
                        return Column(
                          children: [
                            Card(
                              elevation: isSpeaking ? 8 : 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: isSpeaking
                                  ? Colors.yellow.withOpacity(0.15)
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Remove the Row with the icon, just show heading and listen button
                                    Row(
                                      children: [
                                        // Icon removed!
                                        Expanded(
                                          child: Text(
                                            section['heading'],
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: subjectData['color'],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isSpeaking
                                                ? Icons.stop_circle
                                                : Icons.volume_up_rounded,
                                            color: isSpeaking
                                                ? Colors.red
                                                : Colors.blue[700],
                                            size: 28,
                                          ),
                                          onPressed: () => _speak(
                                              section['paragraph'], index),
                                          tooltip:
                                              isSpeaking ? "Stop" : "Listen",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      section['paragraph'],
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (section.containsKey('image'))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            section['image'],
                                            height: 160,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (index != content.length - 1)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[400],
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Icon(Icons.arrow_downward,
                                          color: Colors.grey[400], size: 18),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[400],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
