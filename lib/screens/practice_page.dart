import 'package:flutter/material.dart';
import 'subject_practice_page.dart';

void main() {
  runApp(const MaterialApp(
    home: PracticePage(),
  ));
}

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  PracticePageState createState() => PracticePageState();
}

class PracticePageState extends State<PracticePage> {
  final List<Map<String, dynamic>> _practiceItems = [
    {
      'title': 'Mathematics',
      'subtitle': 'Algebra, Geometry, Calculus',
      'icon': 'https://img.icons8.com/isometric/50/hygrometer.png',
      'color': Colors.blue,
      'chapters': 120, // <-- changed
      'completed': 90,
    },
    {
      'title': 'Science',
      'subtitle': 'Physics, Chemistry, Biology',
      'icon': 'https://img.icons8.com/isometric/50/microscope.png',
      'color': Colors.green,
      'chapters': 150, // <-- changed
      'completed': 90,
    },
    {
      'title': 'English',
      'subtitle': 'Grammar, Vocabulary, Literature',
      'icon': 'https://img.icons8.com/isometric/50/book-shelf.png',
      'color': Colors.purple,
      'chapters': 100, // <-- changed
      'completed': 85,
    },
    {
      'title': 'Social Studies',
      'subtitle': 'History, Geography, Civics',
      'icon': 'https://img.icons8.com/isometric/50/world-map.png',
      'color': Colors.orange,
      'chapters': 80, // <-- changed
      'completed': 36,
    },
    {
      'title': 'Telugu',
      'subtitle': 'Grammar, Literature, Comprehension',
      'icon': 'https://img.icons8.com/isometric/50/literature.png',
      'color': Colors.pink,
      'chapters': 90, // <-- changed
      'completed': 50,
    },
    {
      'title': 'Hindi',
      'subtitle': 'Grammar, Literature, Vocabulary',
      'icon': 'https://img.icons8.com/isometric/50/book-reading.png',
      'color': Colors.amber,
      'chapters': 85, // <-- changed
      'completed': 34,
    },
  ];

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch practice data from backend (API call, database read) */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Practice Zone', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            const Text(
              'Continue Your Practice',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pick up where you left off or start something new',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Practice by subject section
            const Text(
              'Practice by Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._practiceItems.map((item) => _buildPracticeCard(item)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard(Map<String, dynamic> item) {
    return Container(
      // Remove margin-bottom since we're scrolling horizontally now
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to subject practice
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectPracticePage(
                  subjectData: item,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        item['icon'],
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
                            item['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item['subtitle'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: (item['chapters'] > 0)
                                ? (item['completed'] / item['chapters'])
                                : 0.0,
                            backgroundColor: Colors.grey[200],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(item['color']),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${item['completed']} / ${item['chapters']} chapters completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Start practice
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item['color'],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Practice'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
