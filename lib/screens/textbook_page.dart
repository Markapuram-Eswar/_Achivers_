import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  // Font size is now handled by _currentFontSize
  static const double _minFontSize = 12.0;
  static const double _maxFontSize = 32.0;
  String _selectedVoiceGender = 'female';
  List<Map<String, dynamic>> _voices = [];
  double _currentFontSize = 16.0;

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिंदी'];

  List<Map<String, dynamic>> get _content => _selectedLanguage == 'English' ? _englishContent : _hindiContent;

  final List<Map<String, dynamic>> _englishContent = [
    {
      'heading': 'Introduction to Biology',
      'paragraph':
          'Biology is the scientific study of life and living organisms, including their physical structure, chemical processes, molecular interactions, physiological mechanisms, development, and evolution. It encompasses multiple sub-disciplines such as microbiology, botany, zoology, and biochemistry. Modern biology is a vast field composed of many specialized disciplines that study the structure, function, growth, origin, evolution, and distribution of living organisms. The fundamental principles of modern biology include cell theory, evolution, genetics, homeostasis, and energy processing. Biologists study life at multiple levels of organization, from molecular biology of cells to the anatomy and physiology of organisms, and how species interact within ecosystems.',
      'image':
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'Cell Structure and Function',
      'paragraph':
          'Cells are the basic structural and functional units of all living organisms. The human body contains approximately 37.2 trillion cells, each with specialized functions. There are two primary types of cells: prokaryotic cells (bacteria and archaea) and eukaryotic cells (plants, animals, fungi). Key cellular components include the nucleus (containing DNA), mitochondria (powerhouse of the cell), endoplasmic reticulum (protein and lipid synthesis), Golgi apparatus (protein modification and transport), lysosomes (digestive system), and cell membrane (selective barrier). The process of cellular respiration occurs in mitochondria, converting biochemical energy from nutrients into adenosine triphosphate (ATP), while photosynthesis in plant cells converts light energy into chemical energy stored in glucose.',
      'image':
          'https://images.unsplash.com/photo-1532187863485-abdbb168e042?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'Photosynthesis Process',
      'paragraph':
          'Photosynthesis is the biochemical process by which plants, algae, and some bacteria convert light energy, usually from the sun, into chemical energy stored in glucose. This process occurs in the chloroplasts of plant cells, specifically in the thylakoid membranes where chlorophyll pigments absorb light. The overall chemical equation is: 6CO₂ + 6H₂O + light energy → C₆H₁₂O₆ + 6O₂. Photosynthesis consists of two main stages: the light-dependent reactions (which produce ATP and NADPH) and the Calvin cycle (which produces glucose). This process is crucial for life on Earth as it produces oxygen and forms the foundation of the food chain. Factors affecting photosynthesis include light intensity, carbon dioxide concentration, temperature, and water availability.',
      'image':
          'https://images.unsplash.com/photo-1585011658890-be4d3ad65f1b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
  ];

  final List<Map<String, dynamic>> _hindiContent = [
    {
      'heading': 'जीव विज्ञान का परिचय',
      'paragraph':
          'जीव विज्ञान जीवन और जीवित जीवों का वैज्ञानिक अध्ययन है, जिसमें उनकी भौतिक संरचना, रासायनिक प्रक्रियाएं, आणविक अंतःक्रियाएं, शारीरिक तंत्र, विकास और विकास शामिल हैं। इसमें सूक्ष्म जीव विज्ञान, वनस्पति विज्ञान, प्राणी विज्ञान और जैव रसायन जैसे कई उप-विषय शामिल हैं। आधुनिक जीव विज्ञान एक विशाल क्षेत्र है जो जीवित जीवों की संरचना, कार्य, विकास, उत्पत्ति, विकास और वितरण का अध्ययन करता है। आधुनिक जीव विज्ञान के मूल सिद्धांतों में कोशिका सिद्धांत, विकास, आनुवंशिकी, होमियोस्टेसिस और ऊर्जा प्रसंस्करण शामिल हैं।',
      'image':
          'https://images.unsplash.com/photo-1581093450024-af2a3d6dba5a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'कोशिका संरचना और कार्य',
      'paragraph':
          'कोशिकाएं सभी जीवित जीवों की मूल संरचनात्मक और कार्यात्मक इकाइयां हैं। मानव शरीर में लगभग 37.2 ट्रिलियन कोशिकाएं होती हैं, जिनमें से प्रत्येक की विशेष भूमिका होती है। कोशिकाओं के दो मुख्य प्रकार हैं: प्रोकैरियोटिक कोशिकाएं (जीवाणु और आर्किया) और यूकेरियोटिक कोशिकाएं (पौधे, जानवर, कवक)। कोशिका के प्रमुख घटकों में नाभिक (डीएनए युक्त), माइटोकॉन्ड्रिया (कोशिका का पावरहाउस), एंडोप्लाज्मिक रेटिकुलम (प्रोटीन और लिपिड संश्लेषण), गोल्जी उपकरण (प्रोटीन संशोधन और परिवहन), लाइसोसोम (पाचन तंत्र), और कोशिका झिल्ली (चयनात्मक बाधा) शामिल हैं।',
      'image':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'प्रकाश संश्लेषण प्रक्रिया',
      'paragraph':
          'प्रकाश संश्लेषण एक जैव रासायनिक प्रक्रिया है जिसके द्वारा पौधे, शैवाल और कुछ जीवाणु सूर्य के प्रकाश ऊर्जा को ग्लूकोज के रूप में रासायनिक ऊर्जा में परिवर्तित करते हैं। यह प्रक्रिया पौधों के क्लोरोप्लास्ट में होती है, विशेष रूप से थायलाकोइड झिल्ली में जहां क्लोरोफिल वर्णक प्रकाश को अवशोषित करते हैं। समग्र रासायनिक समीकरण है: 6CO₂ + 6H₂O + प्रकाश ऊर्जा → C₆H₁₂O₆ + 6O₂। प्रकाश संश्लेषण में दो मुख्य चरण होते हैं: प्रकाश-निर्भर अभिक्रियाएं (जो एटीपी और एनएडीपीएच उत्पन्न करती हैं) और केल्विन चक्र (जो ग्लूकोज उत्पन्न करता है)। यह प्रक्रिया पृथ्वी पर जीवन के लिए महत्वपूर्ण है क्योंकि यह ऑक्सीजन उत्पन्न करती है और खाद्य श्रृंखला का आधार बनाती है।',
      'image':
          'https://images.unsplash.com/photo-1476231682828-37e95bcad36e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Set default language based on selection
      await _flutterTts.setLanguage(_selectedLanguage == 'English' ? 'en-US' : 'hi-IN');
      
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
        (v) => v['name']?.toString().toLowerCase().contains(gender.toLowerCase()) ?? false,
        orElse: () => _voices.first,
      );

      // Create a new map with required String values
      final Map<String, String> voiceMap = {
        'name': voice['name']?.toString() ?? 'default',
        'locale': voice['locale']?.toString() ?? 'en-US',
        // Add other required fields with defaults if needed
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

      // Set language before speaking
      await _flutterTts.setLanguage(_selectedLanguage == 'English' ? 'en-US' : 'hi-IN');
      
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
      _flutterTts.setErrorHandler((_) {});
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

  void _changeLanguage(String? newValue) {
    if (newValue != null && newValue != _selectedLanguage) {
      setState(() {
        _selectedLanguage = newValue;
        _stopSpeaking(); // Stop any ongoing speech when language changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == 'English' ? 'Biology Textbook' : 'जीव विज्ञान पाठ्यपुस्तक',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          // Language selector dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  icon: const Icon(Icons.language, color: Colors.white),
                  dropdownColor: Theme.of(context).primaryColor,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  onChanged: _changeLanguage,
                  items: _languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: value == 'हिंदी' ? 'Noto Sans Devanagari' : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Font size controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.text_decrease, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (_currentFontSize > _minFontSize) {
                      _currentFontSize -= 2.0;
                    }
                  });
                },
              ),
              Text(
                '${_currentFontSize.toInt()}px',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (_currentFontSize < _maxFontSize) {
                      _currentFontSize += 2.0;
                    }
                  });
                },
              ),
            ],
          ),
          
          // Voice selection
          PopupMenuButton<String>(
            icon: const Icon(Icons.record_voice_over),
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
          // Font size controls moved to the right side of the app bar
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          itemCount: _content.length,
          itemBuilder: (context, index) {
            final section = _content[index];
            final isSpeaking = _currentlySpeakingIndex == index;

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                                  section['heading'],
                                  style: GoogleFonts.poppins(
                                    fontSize: _currentFontSize,
                                    color: Colors.grey[800],
                                    height: 1.6,
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
                                  onTap: isSpeaking
                                      ? _stopSpeaking
                                      : () => _speak(section['paragraph'], index),
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
                              fontSize: _currentFontSize,
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
