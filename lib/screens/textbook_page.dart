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
  double _fontSize = 16.0;
  String _selectedVoice = 'female'; // 'male' or 'female'

  final List<Map<String, dynamic>> _content = [
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
    {
      'heading': 'Human Anatomy and Physiology',
      'paragraph':
          'Human anatomy is the scientific study of the structure of organisms and their parts, while physiology focuses on how those structures function. The human body is organized into several major systems: the skeletal system (206 bones providing structure and protection), muscular system (enabling movement), nervous system (brain, spinal cord, and nerves controlling body functions), cardiovascular system (heart and blood vessels circulating blood), respiratory system (lungs and airways for gas exchange), digestive system (processing food and absorbing nutrients), endocrine system (hormone production and regulation), immune system (defense against pathogens), and reproductive system. Each system works in harmony to maintain homeostasis, the body\'s ability to maintain a stable internal environment despite external changes.',
      'image':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'Genetics and Heredity',
      'paragraph':
          'Genetics is the study of genes, genetic variation, and heredity in organisms. DNA (deoxyribonucleic acid) is the hereditary material in humans and almost all other organisms, containing the instructions needed for development, survival, and reproduction. The structure of DNA is a double helix, discovered by James Watson and Francis Crick in 1953. Genes are segments of DNA that encode specific proteins or functional RNA molecules. The human genome contains approximately 20,000-25,000 genes. Genetic inheritance follows Mendelian patterns, including dominant and recessive traits, codominance, and incomplete dominance. Modern genetics includes molecular genetics (studying gene structure and function), population genetics (studying genetic variation within populations), and quantitative genetics (studying complex traits influenced by multiple genes and environment).',
      'image':
          'https://images.unsplash.com/photo-1581093450024-af2a3d6dba5a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'Evolution and Natural Selection',
      'paragraph':
          'Evolution is the process by which different kinds of living organisms have developed and diversified from earlier forms during the history of Earth. Charles Darwin\'s theory of natural selection explains how evolution occurs: individuals with advantageous traits are more likely to survive and reproduce, passing those traits to future generations. Evidence for evolution comes from multiple sources including the fossil record, comparative anatomy, embryology, biogeography, and molecular biology. Key concepts include genetic variation, mutation, genetic drift, gene flow, and speciation. Evolution explains both the unity (shared characteristics due to common ancestry) and diversity (adaptations to different environments) of life on Earth. Modern evolutionary synthesis combines Darwinian evolution with Mendelian genetics, showing how genetic mutations provide the variation upon which natural selection acts.',
      'image':
          'https://images.unsplash.com/photo-1610337673044-720471f83677?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'Ecology and Ecosystems',
      'paragraph':
          'Ecology is the study of interactions among organisms and between organisms and their physical environment. An ecosystem consists of all the organisms in a particular area along with the nonliving components with which they interact. Key ecological concepts include energy flow (movement of energy through food chains and webs), nutrient cycling (recycling of elements like carbon and nitrogen), and ecological succession (predictable changes in species composition over time). Biomes are large-scale ecological communities characterized by climate and dominant vegetation, such as tropical rainforests, deserts, grasslands, and tundras. Human impacts on ecosystems include habitat destruction, pollution, climate change, and introduction of invasive species. Conservation biology seeks to protect biodiversity and maintain ecosystem services that humans depend on, such as clean air, water, and soil fertility.',
      'image':
          'https://images.unsplash.com/photo-1476231682828-37e95bcad36e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
    {
      'heading': 'Microbiology and Immunology',
      'paragraph':
          'Microbiology is the study of microscopic organisms, including bacteria, viruses, archaea, fungi, and protists. These microorganisms play crucial roles in nutrient cycling, biodegradation, climate change, food spoilage, and human health. The human body hosts trillions of microorganisms, collectively known as the microbiome, which are essential for digestion, vitamin production, and protection against pathogens. Immunology is the study of the immune system, which defends the body against infectious organisms and other invaders. The immune system consists of innate (nonspecific) and adaptive (specific) components. Vaccination works by stimulating the immune system to recognize and combat pathogens. Understanding microbiology and immunology is crucial for developing antibiotics, vaccines, and treatments for infectious diseases, as well as for maintaining public health through sanitation and food safety measures.',
      'image':
          'https://images.unsplash.com/photo-1575505586569-646b2ca898fc?ixlib=rb-1.2.1&auto=format&fit=crop&w=1080&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      // Set voice parameters based on selection
      if (_selectedVoice == 'male') {
        await _flutterTts.setPitch(0.8);
        await _flutterTts.setSpeechRate(0.45);
      } else {
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
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
        // If clicking the same item that's currently speaking, just stop it
        if (_currentlySpeakingIndex == index) {
          return;
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
                  await _initTts(); // Reinitialize TTS with new voice settings
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize - 1).clamp(12.0, 24.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
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
