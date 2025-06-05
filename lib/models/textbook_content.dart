import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class TextbookContent {
  final String language;
  final String subject;
  final String topic;
  final List<Section> sections;
  final String? documentId; // Add this for Firebase document ID

  TextbookContent({
    required this.language,
    required this.subject,
    required this.topic,
    required this.sections,
    this.documentId,
  });

  factory TextbookContent.fromJson(Map<String, dynamic> json) {
    return TextbookContent(
      language: json['language'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((section) => Section.fromJson(section))
              .toList() ??
          [],
    );
  }

  factory TextbookContent.fromFirestore(Map<String, dynamic> json, String id) {
    return TextbookContent(
      documentId: id,
      language: json['language'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      sections: ((json['sections'] ?? []) as List)
          .map((section) => Section.fromFirestore(section))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'subject': subject,
      'topic': topic,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'language': language,
      'subject': subject,
      'topic': topic,
      'sections': sections.map((section) => section.toFirestore()).toList(),
      // Omit documentId when saving to Firestore
    };
  }
}

class Section {
  final String heading;
  final String paragraph;
  final String? image;
  final DateTime? createdAt; // Add timestamp for Firebase

  Section({
    required this.heading,
    required this.paragraph,
    this.image,
    this.createdAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      heading: json['heading'] ?? '',
      paragraph: json['para'] ?? '',
      image: json['img'],
    );
  }

  factory Section.fromFirestore(Map<String, dynamic> json) {
    return Section(
      heading: json['heading'] ?? '',
      paragraph: json['para'] ?? '',
      image: json['img'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'para': paragraph,
      'img': image,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'heading': heading,
      'para': paragraph,
      'img': image,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
