import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
// TODO: Update the import path below to the correct location of app_provider.dart, or create the file if it does not exist.
import 'package:your_project/providers/app_provider.dart'; // Update 'your_project' to your actual project name
import '../models/language_pack.dart'; // Assumed models for LanguagePack and LanguagePackDB
import '../models/translation.dart'; // Assumed model for TranslationDB

// TTSService class
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  Map<String, bool> _languageAvailability = {};

  // Language locale mapping
  final Map<String, String> _languageLocales = {
    'kannada': 'kn-IN',
    'hindi': 'hi-IN',
    'spanish': 'es-ES',
    'french': 'fr-FR',
    'german': 'de-DE',
    'japanese': 'ja-JP',
    'arabic': 'ar-SA',
    'chinese': 'zh-CN',
    'portuguese': 'pt-BR',
    'italian': 'it-IT',
    'english': 'en-US',
    'tamil': 'ta-IN',
    'telugu': 'te-IN',
    'malayalam': 'ml-IN',
  };

  Future<void> initialize() async {
    if (_flutterTts != null) return; // Prevent re-initialization
    _flutterTts = FlutterTts();

    // Set up TTS settings
    await _flutterTts!.setVolume(0.8);
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setPitch(1.0);

    // Check available languages
    await _checkLanguageAvailability();
  }

  Future<void> _checkLanguageAvailability() async {
    if (_flutterTts == null) return;

    try {
      List<dynamic> languages = await _flutterTts!.getLanguages;
      Set<String> availableLocales = languages.cast<String>().toSet();

      for (String languageCode in _languageLocales.keys) {
        String locale = _languageLocales[languageCode]!;
        _languageAvailability[languageCode] = availableLocales.contains(locale);
      }
    } catch (e) {
      print('Error checking TTS language availability: $e');
      for (String languageCode in _languageLocales.keys) {
        _languageAvailability[languageCode] = false;
      }
    }
  }

  bool isLanguageSupported(String languageCode) {
    return _languageAvailability[languageCode] ?? false;
  }

  Future<bool> speak(String text, String languageCode) async {
    if (_flutterTts == null) {
      await initialize();
    }

    if (!_languageLocales.containsKey(languageCode)) {
      print('Unsupported language code: $languageCode');
      return false;
    }

    if (!isLanguageSupported(languageCode)) {
      print('TTS not supported for language: $languageCode');
      return false;
    }

    try {
      String locale = _languageLocales[languageCode]!;
      await _flutterTts!.setLanguage(locale);
      await _flutterTts!.speak(text);
      return true;
    } catch (e) {
      print('Error speaking text: $e');
      return false;
    }
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }

  Future<void> pause() async {
    if (_flutterTts != null) {
      await _flutterTts!.pause();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    if (_flutterTts != null) {
      await _flutterTts!.setSpeechRate(rate);
    }
  }

  Future<void> setVolume(double volume) async {
    if (_flutterTts != null) {
      await _flutterTts!.setVolume(volume);
    }
  }

  Future<void> setPitch(double pitch) async {
    if (_flutterTts != null) {
      await _flutterTts!.setPitch(pitch);
    }
  }

  Map<String, Map<String, dynamic>> getSupportedLanguages() {
    Map<String, Map<String, dynamic>> result = {};
    for (String languageCode in _languageLocales.keys) {
      result[languageCode] = {
        'locale': _languageLocales[languageCode],
        'available': _languageAvailability[languageCode] ?? false,
        'displayName': _getDisplayName(languageCode),
      };
    }
    return result;
  }

  String _getDisplayName(String languageCode) {
    Map<String, String> displayNames = {
      'kannada': 'ಕನ್ನಡ',
      'hindi': 'हिन्दी',
      'spanish': 'Español',
      'french': 'Français',
      'german': 'Deutsch',
      'japanese': '日本語',
      'arabic': 'العربية',
      'chinese': '中文',
      'portuguese': 'Português',
      'italian': 'Italiano',
      'english': 'English',
      'tamil': 'தமிழ்',
      'telugu': 'తెలుగు',
      'malayalam': 'മലയാളം',
    };
    return displayNames[languageCode] ?? languageCode.toUpperCase();
  }

  Future<List<String>> getMissingVoiceInstructions() async {
    List<String> instructions = [];
    for (String languageCode in _languageLocales.keys) {
      if (!isLanguageSupported(languageCode)) {
        String locale = _languageLocales[languageCode]!;
        String displayName = _getDisplayName(languageCode);
        instructions.add(
            'Download voice data for $displayName ($locale) from device settings');
      }
    }
    return instructions;
  }

  Future<void> refreshLanguageAvailability() async {
    await _checkLanguageAvailability();
  }

  void dispose() {
    if (_flutterTts != null) {
      _flutterTts!.stop();
      _flutterTts = null;
    }
  }
}

// LanguagePackScreen
class LanguagePackScreen extends StatefulWidget {
  const LanguagePackScreen({Key? key}) : super(key: key);

  @override
  State<LanguagePackScreen> createState() => _LanguagePackScreenState();
}

class _LanguagePackScreenState extends State<LanguagePackScreen> {
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Initialize TTSService when the screen loads
    TTSService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Packs'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _importLanguagePack,
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Import Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Import Language Pack',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Import JSON language pack files to add new vocabulary.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isImporting ? null : _importLanguagePack,
                        icon: _isImporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label:
                            Text(_isImporting ? 'Importing...' : 'Import Pack'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Installed Packs Section
              const Text(
                'Installed Language Packs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (appProvider.languagePacks.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.language,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No language packs installed',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Import language pack files to get started',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...appProvider.languagePacks.map((pack) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: Switch(
                        value: pack.isEnabled,
                        onChanged: (value) {
                          appProvider.toggleLanguagePack(pack.id!, value);
                        },
                        activeColor: Colors.green,
                      ),
                      title: Text(
                        pack.packName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Version: ${pack.packVersion}'),
                          FutureBuilder<int>(
                            future: appProvider.getWordCountForPack(pack.id!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text('Words: ${snapshot.data}');
                              }
                              return const Text('Words: Loading...');
                            },
                          ),
                          if (!TTSService()
                              .isLanguageSupported(pack.languageCode))
                            Text(
                              'Voice data unavailable',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Created: ${_formatDate(pack.createdAt)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    pack.isDefault
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: pack.isDefault
                                        ? Colors.amber
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    pack.isDefault
                                        ? 'Default Pack'
                                        : 'Custom Pack',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _browsePack(pack),
                                    icon: const Icon(Icons.search),
                                    label: const Text('Browse'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _exportPack(pack),
                                    icon: const Icon(Icons.download),
                                    label: const Text('Export'),
                                  ),
                                  if (!pack.isDefault)
                                    TextButton.icon(
                                      onPressed: () => _deletePack(pack),
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Delete'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _importLanguagePack() async {
    setState(() {
      _isImporting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();

        try {
          Map<String, dynamic> jsonData = json.decode(jsonString);
          LanguagePack languagePack = LanguagePack.fromJson(jsonData);

          await context.read<AppProvider>().importLanguagePack(languagePack);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Successfully imported ${languagePack.packInfo.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error parsing language pack: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _browsePack(LanguagePackDB pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackBrowserScreen(pack: pack),
      ),
    );
  }

  Future<void> _exportPack(LanguagePackDB pack) async {
    // Placeholder: Implement export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
      ),
    );
  }

  Future<void> _deletePack(LanguagePackDB pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Language Pack'),
        content: Text(
            'Are you sure you want to delete "${pack.packName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AppProvider>().deleteLanguagePack(pack.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${pack.packName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// PackBrowserScreen
class PackBrowserScreen extends StatefulWidget {
  final LanguagePackDB pack;

  const PackBrowserScreen({Key? key, required this.pack}) : super(key: key);

  @override
  State<PackBrowserScreen> createState() => _PackBrowserScreenState();
}

class _PackBrowserScreenState extends State<PackBrowserScreen> {
  List<TranslationDB> _translations = [];
  List<TranslationDB> _filteredTranslations = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _searchController.addListener(_filterTranslations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTranslations() async {
    try {
      final databaseService = context.read<AppProvider>();
      // Assumed: Fetch translations from AppProvider/DatabaseService
      final translations =
          await databaseService.getTranslationsForPack(widget.pack.id!);
      setState(() {
        _translations = translations;
        _filteredTranslations = translations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading translations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTranslations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTranslations = _translations.where((translation) {
        return translation.englishWord.toLowerCase().contains(query) ||
            translation.translatedWord.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pack.packName),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vocabulary...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTranslations.isEmpty
                    ? const Center(
                        child: Text(
                          'No vocabulary found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTranslations.length,
                        itemBuilder: (context, index) {
                          final translation = _filteredTranslations[index];
                          return ListTile(
                            title: Text(translation.englishWord),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(translation.translatedWord),
                                if (translation.romanized != null)
                                  Text(
                                    translation.romanized!,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(translation.languageCode.toUpperCase()),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () async {
                                    bool success = await TTSService().speak(
                                      translation.translatedWord,
                                      translation.languageCode,
                                    );
                                    if (!success && context.mounted) {
                                      String displayName =
                                          TTSService().getSupportedLanguages()[
                                                      translation.languageCode]
                                                  ?['displayName'] ??
                                              translation.languageCode;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Pronunciation unavailable for $displayName. Please download voice data.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
