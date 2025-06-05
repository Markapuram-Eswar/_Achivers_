import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/textbook_service.dart';
import '../models/textbook_content.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biology Textbook',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardThemeData(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      home: const TextbookPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TextbookPage extends StatefulWidget {
  const TextbookPage({Key? key}) : super(key: key);

  @override
  _TextbookPageState createState() => _TextbookPageState();
}

class _TextbookPageState extends State<TextbookPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextbookService _textbookService = TextbookService();
  bool _isTtsInitialized = false;
  bool _isSpeaking = false;
  int? _currentlySpeakingIndex;
  String _selectedVoice = 'female';
  String _selectedLanguage = 'ta-IN';
  List<dynamic> _availableVoices = [];
  Map<String, String>? _selectedVoiceParams;
  bool _isWebPlatform = kIsWeb;

  final Map<String, String> _languages = {
    'ta-IN': 'Tamil (India)',
    'te-IN': 'Telugu (India)',
    'ml-IN': 'Malayalam (India)',
    'hi-IN': 'Hindi (India)',
    'kn-IN': 'Kannada (India)',
  };

  final Map<String, String> _localeToLanguage = {
    'ta-IN': 'Tamil',
    'te-IN': 'Telugu',
    'ml-IN': 'Malayalam',
    'hi-IN': 'Hindi',
    'kn-IN': 'Kannada',
  };

  List<TextbookContent> _content = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    if (!_isWebPlatform) {
      _initTts();
    }
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Try loading from cache first
      final cachedContent = await _loadCachedContent();
      if (cachedContent != null && cachedContent.isNotEmpty) {
        setState(() {
          _content = cachedContent;
          _isLoading = false;
        });
        return;
      }

      // Fetch from service
      final content = await _textbookService.fetchTextbookContent(
        language: _selectedLanguage,
      );

      if (content.isEmpty) {
        throw Exception('No content available for $_selectedLanguage');
      }

      await _cacheContent(content.cast<TextbookContent>());

      if (mounted) {
        setState(() {
          _content = content.cast<TextbookContent>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load content: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cacheContent(List<TextbookContent> content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedContent_$_selectedLanguage',
        jsonEncode(content.map((c) => c.toJson()).toList()));
  }

  Future<List<TextbookContent>?> _loadCachedContent() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cachedContent_$_selectedLanguage');
    if (cached != null) {
      final List<dynamic> decoded = jsonDecode(cached);
      return decoded.map((json) => TextbookContent.fromJson(json)).toList();
    }
    return null;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage') ?? 'ta-IN';
    final savedVoice = prefs.getString('selectedVoice') ?? 'female';

    setState(() {
      _selectedLanguage = savedLanguage;
      _selectedVoice = savedVoice;
    });

    // Fetch content to validate language
    final cachedContent = await _loadCachedContent();
    final hasContent = cachedContent
            ?.any((c) => c.language == _localeToLanguage[savedLanguage]) ??
        false;

    if (!hasContent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Content not available for ${_languages[savedLanguage] ?? savedLanguage}. Defaulting to Tamil.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() {
        _selectedLanguage = 'ta-IN';
      });
      await _savePreferences(_selectedVoice, 'ta-IN');
      await _fetchContent();
    }
  }

  Future<void> _savePreferences(String voice, String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVoice', voice);
    await prefs.setString('selectedLanguage', language);
  }

  Future<void> _initTts() async {
    if (_isWebPlatform) return;

    try {
      await _flutterTts.setLanguage(_selectedLanguage);
      _availableVoices = await _flutterTts.getVoices;

      if (_availableVoices.isEmpty) {
        // Fallback to en-US if no voices are available
        await _flutterTts.setLanguage('en-US');
        _selectedVoiceParams = {'name': 'default', 'locale': 'en-US'};
        await _flutterTts.setVoice(_selectedVoiceParams!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No voices available for ${_languages[_selectedLanguage] ?? _selectedLanguage}. Using English voice.',
              ),
            ),
          );
        }
      } else {
        _selectedVoiceParams = _pickVoice(_selectedVoice, _selectedLanguage);
        if (_selectedVoiceParams != null) {
          await _flutterTts.setVoice(_selectedVoiceParams!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No $_selectedVoice voice available for ${_languages[_selectedLanguage] ?? _selectedLanguage}',
              ),
            ),
          );
        }
      }

      await _flutterTts.setPitch(_selectedVoice == 'male' ? 0.9 : 1.1);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingIndex = null;
          });
        }
      });

      _flutterTts.setErrorHandler((msg) {
        if (mounted && !msg.contains('interrupted')) {
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

  Map<String, String>? _pickVoice(String gender, String language) {
    if (_availableVoices.isEmpty) return null;

    final languageCode = language.toLowerCase().split('-')[0];
    final languageVoices = _availableVoices
        .where(
          (v) => v['locale']?.toLowerCase().startsWith(languageCode) ?? false,
        )
        .toList();

    if (languageVoices.isEmpty) {
      return Map<String, String>.from(_availableVoices.first);
    }

    final genderMatch = languageVoices.firstWhere(
      (v) => v['gender']?.toLowerCase() == gender,
      orElse: () => null,
    );
    if (genderMatch != null) {
      return Map<String, String>.from(genderMatch);
    }

    final nameMatch = languageVoices.firstWhere(
      (v) => v['name']?.toLowerCase().contains(gender) ?? false,
      orElse: () => null,
    );
    if (nameMatch != null) {
      return Map<String, String>.from(nameMatch);
    }

    final defaultVoice = languageVoices.firstWhere(
      (v) => v['name']?.toLowerCase().contains('default') ?? false,
      orElse: () => languageVoices.first,
    );
    return Map<String, String>.from(defaultVoice);
  }

  Future<void> _speak(String text, int index) async {
    if (_isWebPlatform) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text-to-speech is not supported on web.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        if (_currentlySpeakingIndex == index) {
          setState(() {
            _isSpeaking = false;
            _currentlySpeakingIndex = null;
          });
          return;
        }
      }

      if (!_isTtsInitialized) {
        await _initTts();
      }

      if (_selectedVoiceParams == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No voice selected')),
          );
        }
        return;
      }

      setState(() {
        _currentlySpeakingIndex = index;
        _isSpeaking = true;
      });

      await _flutterTts.setVoice(_selectedVoiceParams!);
      await _flutterTts.speak(text);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_isWebPlatform) {
      _flutterTts.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Biology Textbook',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.green[700],
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<String>(
            value: _selectedLanguage,
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.green[700],
            style: GoogleFonts.poppins(color: Colors.white),
            underline: Container(height: 0),
            items: _languages.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(entry.value, style: GoogleFonts.poppins()),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              if (newValue != null && newValue != _selectedLanguage) {
                setState(() {
                  _selectedLanguage = newValue;
                });
                await _savePreferences(_selectedVoice, newValue);
                if (!_isWebPlatform) {
                  await _initTts();
                }
                await _fetchContent();
              }
            },
          ),
        ),
        if (!_isWebPlatform)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedVoice,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.green[700],
              style: GoogleFonts.poppins(color: Colors.white),
              underline: Container(height: 0),
              items: [
                DropdownMenuItem(
                  value: 'female',
                  child: Row(
                    children: [
                      const Icon(Icons.female, color: Colors.pink),
                      const SizedBox(width: 8),
                      Text('Female Voice', style: GoogleFonts.poppins()),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'male',
                  child: Row(
                    children: [
                      const Icon(Icons.male, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Male Voice', style: GoogleFonts.poppins()),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) async {
                if (newValue != null && newValue != _selectedVoice) {
                  setState(() {
                    _selectedVoice = newValue;
                  });
                  await _savePreferences(newValue, _selectedLanguage);
                  if (!_isWebPlatform) {
                    await _initTts();
                  }
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Error message',
              child: Text(
                _errorMessage,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Retry',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_content.isEmpty) {
      return Center(
        child: Text(
          'No content available',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _content.length,
      itemBuilder: (context, index) {
        final content = _content[index];
        return _buildContentCard(content, index);
      },
    );
  }

  Widget _buildContentCard(TextbookContent content, int cardIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Subject: ${content.subject}',
                  child: Text(
                    content.subject,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Topic: ${content.topic}',
                  child: Text(
                    content.topic,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: content.sections.length,
            itemBuilder: (context, index) {
              return _buildSection(
                  content.sections[index], cardIndex * 1000 + index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Section section, int index) {
    final isSpeaking = _currentlySpeakingIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (section.image != null)
            Semantics(
              label: 'Image for ${section.heading}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Stack(
                  children: [
                    Image.network(
                      section.image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
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
                          section.heading,
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
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (section.image == null)
                      Expanded(
                        child: Semantics(
                          label: 'Section heading: ${section.heading}',
                          child: Text(
                            section.heading,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ),
                      ),
                    if (!_isWebPlatform)
                      Container(
                        decoration: BoxDecoration(
                          color: isSpeaking ? Colors.red[50] : Colors.green[50],
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
                            onTap: () => _speak(section.paragraph, index),
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
                Semantics(
                  label: 'Section content: ${section.paragraph}',
                  child: Text(
                    section.paragraph,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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
    );
  }
}

class TextbookContent {
  final String subject;
  final String topic;
  final List<Section> sections;
  final String language;

  TextbookContent({
    required this.subject,
    required this.topic,
    required this.sections,
    required this.language,
  });

  factory TextbookContent.fromJson(Map<String, dynamic> json) {
    return TextbookContent(
      subject: json['subject'],
      topic: json['topic'],
      sections: (json['sections'] as List)
          .map((section) => Section.fromJson(section))
          .toList(),
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'sections': sections.map((s) => s.toJson()).toList(),
      'language': language,
    };
  }
}
