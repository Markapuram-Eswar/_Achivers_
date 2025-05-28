import 'package:flutter/material.dart';

class TextbookPage extends StatelessWidget {
  final Map<String, dynamic> subjectData;
  final Map<String, dynamic> topicData;

  const TextbookPage({
    super.key,
    required this.subjectData,
    required this.topicData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${topicData['title']} Textbook',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: subjectData['color'],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter header
            _buildChapterHeader(),
            const SizedBox(height: 24),

            // Chapter content
            _buildChapterContent(),

            // Navigation buttons
            const SizedBox(height: 32),
            _buildNavigationButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: subjectData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subjectData['color'].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: subjectData['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  topicData['icon'],
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topicData['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chapter 1: Introduction to ${topicData['title']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChapterContent() {
    // This would ideally come from a database or API
    // For now, we'll create sample content based on the topic
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Introduction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome to the ${topicData['title']} chapter. This section will introduce you to the fundamental concepts and principles of ${topicData['title']}.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Key Concepts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildKeyConceptsList(),
        const SizedBox(height: 24),

        const Text(
          'Detailed Explanation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'In ${topicData['title']}, we study how various elements interact and form the basis of our understanding. The principles established here will be used throughout your academic journey.\n\nThe field of ${topicData['title']} has evolved significantly over the centuries, with contributions from many notable scholars and researchers. Their work has shaped our current understanding and continues to influence modern applications.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Example or illustration
        _buildExampleBox(),
        const SizedBox(height: 24),

        // Summary
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'In this chapter, we introduced the basic concepts of ${topicData['title']}. We explored the key principles and examined some practical examples. In the next chapter, we will delve deeper into advanced topics and applications.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyConceptsList() {
    final List<String> concepts = [
      'Fundamental principles of ${topicData['title']}',
      'Historical development and key contributors',
      'Basic terminology and definitions',
      'Practical applications and real-world examples',
      'Modern advancements and future directions'
    ];

    return Column(
      children: concepts
          .map((concept) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: subjectData['color']),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        concept,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildExampleBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example: Application of ${topicData['title']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: subjectData['color'],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Consider a scenario where we apply these principles to solve a real-world problem. By following the steps outlined in this chapter, we can analyze the situation and develop an effective solution.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Step 1: Identify the problem\nStep 2: Apply relevant principles\nStep 3: Develop a solution approach\nStep 4: Implement and evaluate',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to previous chapter
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Previous'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to practice section
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Moving to practice questions'),
                backgroundColor: subjectData['color'],
              ),
            );
          },
          icon: const Icon(Icons.fitness_center),
          label: const Text('Practice'),
          style: ElevatedButton.styleFrom(
            backgroundColor: subjectData['color'],
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to next chapter
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Moving to next chapter'),
                backgroundColor: subjectData['color'],
              ),
            );
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
          ),
        ),
      ],
    );
  }
}
