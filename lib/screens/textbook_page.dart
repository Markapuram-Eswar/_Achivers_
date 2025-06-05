import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/text_book_service.dart';
import '../services/ProfileService.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TextbookPage extends StatefulWidget {
  final Map<String, dynamic> subjectData;
  final Map<String, dynamic> topicData;

  const TextbookPage({
    super.key,
    required this.subjectData,
    required this.topicData,
  });

  @override
  State<TextbookPage> createState() => _TextbookPageState();
}

class _TextbookPageState extends State<TextbookPage> {
  // Services from first file
  final TextBookService _textBookService = TextBookService();
  Map<String, dynamic>? studentData;
  
  // TTS and UI state from second file
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;
  bool _isSpeaking = false;
  int? _currentlySpeakingIndex;
  double _fontSize = 16.0;
  String _selectedVoiceGender = 'female';
  List<Map<String, dynamic>> _voices = [];
  
  // Data state combining both files
  Future<Map<String, dynamic>> _textbookData = Future.value({});
  String? errorMessage;
  bool isLoading = true;
  List<dynamic> _content = [];

  @override
  void initState() {
    super.initState();
    print('Textbook Page ${widget.subjectData}');
    print('Textbook Page ${widget.topicData}');
    _loadData();
    _initTts();
  }

  // Backend logic from first file
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

      // Extract content array and set it for the UI
      final contentArray = content["content"] ?? [];
      
      // Wrap the Firestore content in the structure expected by the UI
      setState(() {
        _textbookData = Future.value({
          "subjectData": {
            "id": subject,
            "name": subject,
            "color": widget.subjectData["color"] ?? Colors.green[700],
          },
          "topicData": {
            "id": topic,
            "title": topic,
            "icon": widget.topicData["icon"] ?? "",
            "content": contentArray,
          }
        });
        _content = contentArray;
      });
    } catch (e) {
      setState(() => errorMessage = 'Failed to fetch textbook data: $e');
      
      // Fallback to demo data if service fails
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    final fallbackContent = [
      {
        'heading': 'Introduction to ${widget.topicData['name'] ?? 'Topic'}',
        'paragraph': 'This is an introduction to the topic. Content will be loaded from your curriculum.',
        'image': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
      },
    ];

    setState(() {
      _textbookData = Future.value({
        "subjectData": {
          "id": widget.subjectData['title'] ?? 'subject',
          "name": widget.subjectData['title'] ?? 'Subject',
          "color": widget.subjectData["color"] ?? Colors.green[700],
        },
        "topicData": {
          "id": widget.topicData['name'] ?? 'topic',
          "title": widget.topicData['name'] ?? 'Topic',
          "icon": widget.topicData["icon"] ?? "",
          "content": fallbackContent,
        }
      });
      _content = fallbackContent;
    });
  }

  // Enhanced TTS initialization from second file
  Future<void> _initTts() async {
    try {
      // Get available voices
      var voices = await _flutterTts.getVoices;

      // Safely convert voices to the correct type
      if (voices != null) {
        _voices = [];
        for (var voice in voices) {
          if (voice is Map) {
            try {
              _voices.add(Map<String, dynamic>.from(voice));
            } catch (e) {
              debugPrint('Error converting voice: $e');
            }
          }
        }
      }

      // Set TTS parameters
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      // Set initial voice based on gender if voices are available
      if (_voices.isNotEmpty) {
        await _setVoiceGender(_selectedVoiceGender);
      }

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

  Future<void> _setVoiceGender(String gender) async {
    try {
      if (_voices.isEmpty) {
        debugPrint('No voices available');
        return;
      }

      // Find a voice that matches the gender
      var voice = _voices.firstWhere(
        (v) =>
            v['name']
                ?.toString()
                .toLowerCase()
                .contains(gender.toLowerCase()) ??
            false,
        orElse: () => _voices.first,
      );

      // Create a new map with required String values
      final Map<String, String> voiceMap = {
        'name': voice['name']?.toString() ?? 'default',
        'locale': voice['locale']?.toString() ?? 'en-US',
      };

      await _flutterTts.setVoice(voiceMap);

      if (mounted) {
        setState(() {
          _selectedVoiceGender = gender;
        });
      }
    } catch (e) {
      debugPrint('Error in _setVoiceGender: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error setting voice. Using default voice settings.'),
            duration: Duration(seconds: 2),
          ),
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

      if (!_isTtsInitialized) {
        await _initTts();
      }

      if (mounted) {
        setState(() {
          _currentlySpeakingIndex = index;
          _isSpeaking = true;
        });
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

  Future<void> _stopSpeaking() async {
    try {
      // First cancel any ongoing speech
      await _flutterTts.stop();

      // Reset the speaking state
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingIndex = null;
        });
      }

      // Add a small delay to ensure the state is properly updated
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error in _stopSpeaking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error stopping speech'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    try {
      // Stop any ongoing speech
      _flutterTts.stop();

      // Clear all handlers with empty callbacks
      _flutterTts.setCompletionHandler(() {});
      _flutterTts.setErrorHandler((msg) {});
      _flutterTts.setCancelHandler(() {});

      // Reset state
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingIndex = null;
        });
      }
    } catch (e) {
      debugPrint('Error in dispose: $e');
    } finally {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Loading...',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: widget.subjectData["color"] ?? Colors.green[700],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Error',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: widget.subjectData["color"] ?? Colors.green[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                    isLoading = true;
                  });
                  _loadData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _textbookData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Loading...',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: widget.subjectData["color"] ?? Colors.green[700],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Error',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: widget.subjectData["color"] ?? Colors.green[700],
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'No Data',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: widget.subjectData["color"] ?? Colors.green[700],
            ),
            body: const Center(child: Text('No textbook data found.')),
          );
        }

        final subjectData = data['subjectData'] ?? {};
        final topicData = data['topicData'] ?? {};
        final List<dynamic> content = topicData['content'] ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              topicData['title'] ?? 'Textbook',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: subjectData['color'] ?? Colors.green[700],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Voice selection
              PopupMenuButton<String>(
                icon: const Icon(Icons.record_voice_over, color: Colors.white),
                onSelected: _setVoiceGender,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'female',
                    child: Row(
                      children: [
                        Icon(
                          Icons.female,
                          color: _selectedVoiceGender == 'female'
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Female Voice',
                          style: GoogleFonts.poppins(),
                        ),
                        if (_selectedVoiceGender == 'female')
                          const Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'male',
                    child: Row(
                      children: [
                        Icon(
                          Icons.male,
                          color: _selectedVoiceGender == 'male'
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Male Voice',
                          style: GoogleFonts.poppins(),
                        ),
                        if (_selectedVoiceGender == 'male')
                          const Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.text_decrease, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _fontSize = (_fontSize - 1).clamp(12.0, 24.0);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.text_increase, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _fontSize = (_fontSize + 1).clamp(12.0, 24.0);
                  });
                },
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (subjectData['color'] ?? Colors.green[700]).withOpacity(0.1),
                  Colors.white
                ],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              itemCount: content.length,
              itemBuilder: (context, index) {
                final section = content[index];
                final isSpeaking = _currentlySpeakingIndex == index;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (section['image'] != null)
                        Hero(
                          tag: 'image_$index',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15.0)),
                            child: Stack(
                              children: [
                                Image.network(
                                  section['image'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress.expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported,
                                            size: 50, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      section['heading'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                      section['heading'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: subjectData['color'] ?? Colors.green[900],
                                      ),
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isSpeaking
                                        ? Colors.red[50]
                                        : (subjectData['color'] ?? Colors.green[700]).withOpacity(0.1),
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
                                      onTap: isSpeaking
                                          ? _stopSpeaking
                                          : () =>
                                              _speak(section['paragraph'] ?? '', index),
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
                                                  : subjectData['color'] ?? Colors.green[700],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isSpeaking ? 'Stop' : 'Listen',
                                              style: GoogleFonts.poppins(
                                                color: isSpeaking
                                                    ? Colors.red
                                                    : subjectData['color'] ?? Colors.green[700],
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
                              data: section['paragraph'] ?? '',
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
            backgroundColor: subjectData['color'] ?? Colors.green[700],
          ),
        );
      },
    );
  }
}

class _ContentSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> content;

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
      final heading = (section['heading'] ?? '').toString().toLowerCase();
      final paragraph = (section['paragraph'] ?? '').toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return heading.contains(searchQuery) || paragraph.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final section = results[index];
        return ListTile(
          title: Text(
            section['heading'] ?? '',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            section['paragraph'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(),
          ),
          onTap: () {
            close(context, section['heading'] ?? '');
          },
        );
      },
    );
  }
}