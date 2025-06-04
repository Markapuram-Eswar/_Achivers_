import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/text_book_service.dart';
import '../services/ProfileService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class TextbookPage extends StatefulWidget {
  final Map<String, dynamic> subjectData;
  final Map<String, dynamic> topicData;

  const TextbookPage({
    super.key,
    required this.subjectData,
    required this.topicData,
  });


  @override
  _TextbookPageState createState() => _TextbookPageState();
}

class _TextbookPageState extends State<TextbookPage> {
  final TextBookService _textBookService = TextBookService();
  late Future<Map<String, dynamic>> _textbookData;
  Map<String, dynamic>? studentData;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;
  bool _isSpeaking = false;
  int? _currentlySpeakingIndex;
  String? errorMessage;
  bool isLoading = true;
  double _fontSize = 16.0;
  @override
  void initState() {
    super.initState();
    print('Textbook Page ${widget.subjectData}');
    print('Textbook Page ${widget.topicData}');
    _loadData();
    _initTts();
  }

  Future<void> _loadData() async {
    try {
      // Fetch student profile first
      final profileData = await ProfileService().getStudentProfile();
      setState(() => studentData = profileData);
      
      // Then fetch practice items using school/class from profile
      await _fetchTextbookData();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTextbookData() async {
    // For now, use hardcoded school and grade, or get from widget.subjectData if available
    final school = studentData?['school']?.toString() ?? '';
    final grade = studentData?['class']?.toString() ?? '';
    final subject = widget.subjectData['title']?.toString() ?? '';
    final topic = widget.topicData['name']?.toString() ?? '';

    print('Student school: $school, class: $grade');

    try {
      final content = await _textBookService.getTextbookContent(
        school: school,
        grade: grade,
        subject: subject,
        topic: topic,
      );

      print('Content: $content');

      if (content == null || content.isEmpty) {
        setState(() => errorMessage = 'No content found for your class');
        return;
      }

      // Wrap the Firestore content in the structure expected by the UI
      setState(() => _textbookData = Future.value({
        "subjectData": {
          "id": subject,
          "name": subject,
          "color": widget.subjectData["color"] ?? const Color(0xFF2196F3),
        },
        "topicData": {
          "id": topic,
          "title": topic,
          "icon": widget.topicData["icon"] ?? "",
          "content": content["content"] ?? [],
        }
      }));
    } catch (e) {
      setState(() => errorMessage = 'Failed to fetch textbook data: $e');
    }
  }


  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _currentlySpeakingIndex = null;
            _isSpeaking = false;
          });
        }
      });

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
      if (_isSpeaking) {
        await _flutterTts.stop();
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingIndex = null;
          });
          if (_currentlySpeakingIndex == index) return;
        }
      }

      if (mounted) {
        setState(() {
          _currentlySpeakingIndex = index;
          _isSpeaking = true;
        });
      }

      if (!_isTtsInitialized) {
        await _initTts();
      }

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
          final data = snapshot.data;
          if (data == null || data['subjectData'] == null || data['topicData'] == null) {
            return const Scaffold(
              body: Center(child: Text('No textbook data found.')),
            );
          }
          final subjectData = data['subjectData'] ?? {};
          final topicData = data['topicData'] ?? {};
          final List<dynamic> content = topicData['content'] ?? [];

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
                      Expanded(
                        child: Text(
                          section['heading'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),

                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (section['image'] == null)
                              Expanded(
                                child: Text(
                                  section['heading'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                color: isSpeaking
                                    ? Colors.red[50]
                                    : Colors.green[50],
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () =>
                                      _speak(section['paragraph'], index),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSpeaking
                                              ? Icons.stop_circle_outlined
                                              : Icons.volume_up_rounded,
                                          color: isSpeaking
                                              ? Colors.red
                                              : Colors.green[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isSpeaking ? 'Stop' : 'Listen',
                                          style: GoogleFonts.poppins(
                                            color: isSpeaking
                                                ? Colors.red
                                                : Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        MarkdownBody(
                          data: section['paragraph'],
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.poppins(
                              fontSize: _fontSize,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                .slideX(begin: 0.2, end: 0);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showSearch(
            context: context,
            delegate: _ContentSearchDelegate(_content),
          );
        },
        label: Text(
          'Search',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.search),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}

class _ContentSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> content;

  _ContentSearchDelegate(this.content);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = content.where((section) {
      final heading = section['heading'].toString().toLowerCase();
      final paragraph = section['paragraph'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return heading.contains(searchQuery) || paragraph.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final section = results[index];
        return ListTile(
          title: Text(
            section['heading'],
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            section['paragraph'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(),
          ),
          onTap: () {
            close(context, section['heading']);
          },
        );
      },
    );
  }
}
