import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;
  static const String _apiKey = 'AIzaSyAgS60oWZtnBaxLsUXLKtgvmurfD4NsjSY';

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.5,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );
  }

  String _getSystemPrompt() {
    return """
    You are StudyMate, an AI teaching assistant designed to help students with their academic questions. 
    Follow these guidelines when responding:
    
    1. Be clear, concise, and accurate in your explanations
    2. Break down complex concepts into simple, easy-to-understand steps
    3. When solving problems, show your work and explain each step
    4. If a question is unclear, ask for clarification
    5. For math/science problems, use appropriate notation and units
    6. If you're not sure about something, say so rather than guessing
    7. Keep responses focused on the academic topic
    8. Be encouraging and supportive in your tone
    
    Remember: Your goal is to help students learn and understand, not just provide answers.
    """;
  }

  Future<String> generateResponse(String prompt) async {
    try {
      final systemPrompt = _getSystemPrompt();
      final content = [
        Content.text(systemPrompt),
        Content.text('Student: $prompt\n\nStudyMate: '),
      ];

      final response = await _model.generateContent(content);
      final responseText =
          response.text?.trim() ?? 'Sorry, I could not generate a response.';

      // Remove any potential system prompt leakage
      return responseText.replaceAll(
          RegExp(r'^StudyMate:\s*', multiLine: true), '');
    } catch (e) {
      if (kDebugMode) {
        print('Error in generateResponse: $e');
      }
      return 'I encountered an error while processing your request. Please try again in a moment.';
    }
  }

  Future<String> analyzeImage(String imagePath, String prompt) async {
    try {
      final systemPrompt = _getSystemPrompt();
      final imageBytes = await File(imagePath).readAsBytes();

      // First, analyze the image content
      final content = [
        Content.multi([
          TextPart('$systemPrompt\n\n$prompt\n\nStudyMate: '),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3, // Lower temperature for more factual responses
          topP: 0.9,
          topK: 32,
          maxOutputTokens: 2048,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
        ],
      );

      final response = await model.generateContent(content);
      final responseText =
          response.text?.trim() ?? 'Sorry, I could not analyze the image.';
      return responseText;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
