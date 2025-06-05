import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Main function to set up MaterialApp
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
  bool _isTtsInitialized = false;
  bool _isSpeaking = false;
  int? _currentlySpeakingIndex;
  String _selectedVoice = 'female'; // Default voice
  String _selectedLanguage = 'ta-IN'; // Default to Tamil
  List<dynamic> _availableVoices = [];
  Map<String, String>? _selectedVoiceParams;

  // Supported languages
  final Map<String, String> _languages = {
    'ta-IN': 'Tamil (India)',
    'te-IN': 'Telugu (India)',
    'ml-IN': 'Malayalam (India)',
  };

  // Map locale to language name in _content
  final Map<String, String> _localeToLanguage = {
    'ta-IN': 'Tamil',
    'te-IN': 'Telugu',
    'ml-IN': 'Malayalam',
  };

  // Content list for multiple languages
  final List<Map<String, dynamic>> _content = [
    {
      "language": "Tamil",
      "data": [
        {
          "heading": "உயிரியல் அறிமுகம்",
          "paragraph":
              "உயிரியல் என்பது உயிருள்ள உயிரினங்களைப் பற்றிய ஆய்வாகும். இது வாழ்க்கையின் பல அம்சங்களை உள்ளடக்கியது, இதில் அமைப்பு, செயல்பாடு, வளர்ச்சி, பரிணாமம் மற்றும் பகிர்வு அடங்கும்.",
          "image":
              "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        },
        {
          "heading": "செல் அமைப்பு",
          "paragraph":
              "செல்ல்கள் வாழ்க்கையின் அடிப்படை அலகுகள். அனைத்து உயிரினங்களும் செல்ல்கள் கொண்டு உருவாகியவை, அவை உயிர் வாழ தேவையான முக்கிய செயல்களைச் செய்கின்றன.",
          "image": null,
        },
        {
          "heading": "மரபியல்",
          "paragraph":
              "மரபியல் என்பது உயிரினங்களில் மரபியல் மற்றும் வேறுபாடுகளைப் பற்றிய ஆய்வாகும். இது பண்புகள் பெற்றோர் மூலம் பிள்ளைகளுக்குப் பிற்பற்றப்படுவது எப்படி என்பதை விளக்குகிறது.",
          "image": null,
        },
      ],
    },
    {
      "language": "Telugu",
      "data": [
        {
          "heading": "జీవశాస్త్ర పరిచయం",
          "paragraph":
              "జీవశాస్త్రం అనేది జీవుల అధ్యయనం. ఇది నిర్మాణం, ఫంక్షన్, వృద్ధి, పరిణామం మరియు పంపిణీ వంటి జీవితం యొక్క వివిధ కోణాలను కవర్ చేస్తుంది.",
          "image":
              "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        },
        {
          "heading": "కణ నిర్మాణం",
          "paragraph":
              "కణాలు అనేవి జీవితం యొక్క మౌలికమైన అంకాలు. అన్ని జీవులు కణాల నుండి ఏర్పడతాయి మరియు అవి జీవించడానికి అవసరమైన ముఖ్యమైన పనులను నిర్వహిస్తాయి.",
          "image": null,
        },
        {
          "heading": "జన్యుపరంపరశాస్త్రం",
          "paragraph":
              "జన్యుపరంపరశాస్త్రం అనేది వారసత్వం మరియు జీవుల్లో వైవిధ్యాన్ని అధ్యయనం చేస్తుంది. ఇది లక్షణాలు తల్లిదండ్రుల నుండి పిల్లలకు ఎలా బదిలీ అవుతాయో వివరిస్తుంది.",
          "image": null,
        },
      ],
    },
    {
      "language": "Malayalam",
      "data": [
        {
          "heading": "ജീവശാസ്ത്രത്തിന് പരിചയം",
          "paragraph":
              "ജീവശാസ്ത്രം എന്നത് ജീവനുള്ള ജീവികളെ കുറിച്ചുള്ള പഠനമാണ്. ഇതിൽ ഘടന, പ്രവർത്തനം, വളർച്ച, പരിണാമം, വിതരണം തുടങ്ങിയവ ഉൾപ്പെടുന്നു.",
          "image":
              "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
        },
        {
          "heading": "കോശഘടന",
          "paragraph":
              "കോശങ്ങൾ ജീവന്റെ അടിസ്ഥാന ഘടകങ്ങളാണ്. എല്ലാ ജീവനുകളും കോശങ്ങളാൽ നിർമ്മിതമാണ്, അവ ജീവൻ നിലനിർത്തുന്നതിനാവശ്യമായ അടിസ്ഥാന പ്രവർത്തനങ്ങൾ നടത്തുന്നു.",
          "image": null,
        },
        {
          "heading": "ജനിതശാസ്ത്രം",
          "paragraph":
              "ജനിതശാസ്ത്രം എന്നത് ജീവികളിൽ മാതാവിൽ നിന്ന് മക്കൾക്ക് സ്വഭാവങ്ങൾ എങ്ങനെ പകരപ്പെടുന്നു എന്നതുമായി ബന്ധപ്പെട്ട പഠനമാണ്.",
          "image": null,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initTts();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage') ?? 'ta-IN';
    final savedVoice = prefs.getString('selectedVoice') ?? 'female';

    // Check if content exists for the saved language
    final languageName = _localeToLanguage[savedLanguage];
    final hasContent = _content.any((lang) => lang['language'] == languageName);

    setState(() {
      _selectedLanguage = hasContent ? savedLanguage : 'ta-IN';
      _selectedVoice = savedVoice;
    });

    if (!hasContent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Content not available for ${_languages[savedLanguage] ?? savedLanguage}. Defaulting to Tamil.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _savePreferences(String voice, String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVoice', voice);
    await prefs.setString('selectedLanguage', language);
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage(_selectedLanguage);
      _availableVoices = await _flutterTts.getVoices;

      if (_availableVoices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No voices available on this device')),
          );
        }
        return;
      }

      _selectedVoiceParams = _pickVoice(_selectedVoice, _selectedLanguage);
      if (_selectedVoiceParams != null) {
        await _flutterTts.setVoice(_selectedVoiceParams!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'No $_selectedVoice voice available for ${_languages[_selectedLanguage] ?? _selectedLanguage}'),
            ),
          );
        }
      }

      // Voice-specific settings
      if (_selectedVoice == 'male') {
        await _flutterTts.setPitch(0.9);
        await _flutterTts.setSpeechRate(0.5);
      } else {
        await _flutterTts.setPitch(1.1);
        await _flutterTts.setSpeechRate(0.5);
      }

      await _flutterTts.setVolume(1.0);

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
          if (!msg.contains('interrupted')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('TTS Error: $msg')),
            );
          }
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

    // Filter voices by language (e.g., 'ta' for 'ta-IN')
    final languageCode = language.toLowerCase().split('-')[0];
    final languageVoices = _availableVoices
        .where(
          (v) => v['locale']?.toLowerCase().startsWith(languageCode) ?? false,
        )
        .toList();

    if (languageVoices.isEmpty) {
      // Fallback to any voice
      return Map<String, String>.from(_availableVoices.first);
    }

    // Try to find a voice with explicit gender property
    final genderMatch = languageVoices.firstWhere(
      (v) => v['gender']?.toLowerCase() == gender,
      orElse: () => null,
    );
    if (genderMatch != null) {
      return Map<String, String>.from(genderMatch);
    }

    // Fallback to name containing gender
    final nameMatch = languageVoices.firstWhere(
      (v) => v['name']?.toLowerCase().contains(gender) ?? false,
      orElse: () => null,
    );
    if (nameMatch != null) {
      return Map<String, String>.from(nameMatch);
    }

    // Platform-specific fallback within the language
    final defaultVoice = languageVoices.firstWhere(
      (v) => v['name']?.toLowerCase().contains('default') ?? false,
      orElse: () => languageVoices.first,
    );
    return Map<String, String>.from(defaultVoice);
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
        }
        if (_currentlySpeakingIndex == index) {
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
    // Get the content for the selected language
    final languageName = _localeToLanguage[_selectedLanguage] ?? 'Tamil';
    final selectedContent = _content.firstWhere(
      (lang) => lang['language'] == languageName,
      orElse: () => _content.first,
    );
    final List<Map<String, dynamic>> sections = selectedContent['data'];

    return Scaffold(
      appBar: AppBar(
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
          // Language selection dropdown
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
                  final languageName = _localeToLanguage[newValue];
                  final hasContent =
                      _content.any((lang) => lang['language'] == languageName);

                  if (!hasContent && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Content not available for ${_languages[newValue] ?? newValue}. Defaulting to Tamil.',
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                    setState(() {
                      _selectedLanguage = 'ta-IN';
                    });
                    await _savePreferences(_selectedVoice, 'ta-IN');
                  } else {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                    await _savePreferences(_selectedVoice, newValue);
                    await _initTts(); // Reinitialize TTS for new language
                  }
                }
              },
            ),
          ),
          // Voice selection dropdown
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
                  await _initTts(); // Reinitialize TTS for new voice
                }
              },
            ),
          ),
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
        child: sections.isEmpty
            ? const Center(child: Text('No content available'))
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  final isSpeaking = _currentlySpeakingIndex == index;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (section['image'] != null)
                          ClipRRect(
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
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              Text(
                                section['paragraph'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
