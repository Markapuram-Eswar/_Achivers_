import 'package:flutter/material.dart';
import 'subject_practice_page.dart';

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
      'progress': 0.75,
      'questions': 120,
      'completed': 90,
    },
    {
      'title': 'Science',
      'subtitle': 'Physics, Chemistry, Biology',
      'icon': 'https://img.icons8.com/isometric/50/microscope.png',
      'color': Colors.green,
      'progress': 0.60,
      'questions': 150,
      'completed': 90,
    },
    {
      'title': 'English',
      'subtitle': 'Grammar, Vocabulary, Literature',
      'icon': 'https://img.icons8.com/isometric/50/book-shelf.png',
      'color': Colors.purple,
      'progress': 0.85,
      'questions': 100,
      'completed': 85,
    },
    {
      'title': 'Social Studies',
      'subtitle': 'History, Geography, Civics',
      'icon': 'https://img.icons8.com/isometric/50/world-map.png',
      'color': Colors.orange,
      'progress': 0.45,
      'questions': 80,
      'completed': 36,
    },
    {
      'title': 'Telugu',
      'subtitle': 'Grammar, Literature, Comprehension',
      'icon': 'https://img.icons8.com/isometric/50/literature.png',
      'color': Colors.pink,
      'progress': 0.55,
      'questions': 90,
      'completed': 50,
    },
    {
      'title': 'Hindi',
      'subtitle': 'Grammar, Literature, Vocabulary',
      'icon': 'https://img.icons8.com/isometric/50/book-reading.png',
      'color': Colors.amber,
      'progress': 0.40,
      'questions': 85,
      'completed': 34,
    },
  ];

  final List<Map<String, dynamic>> _recentPractice = [
    {
      'title': 'Algebra Quiz',
      'subject': 'Mathematics',
      'date': 'Yesterday',
      'score': '85%',
      'color': Colors.blue,
    },
    {
      'title': 'Physics Formulas',
      'subject': 'Science',
      'date': '2 days ago',
      'score': '92%',
      'color': Colors.green,
    },
    {
      'title': 'Grammar Test',
      'subject': 'English',
      'date': '3 days ago',
      'score': '78%',
      'color': Colors.purple,
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

            // Recent practice section
            const Text(
              'Recent Practice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentPractice.take(2).length,
                itemBuilder: (context, index) {
                  final item = _recentPractice[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: item['color'].withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item['subject'],
                              style: TextStyle(
                                color: item['color'],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['date'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['score'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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

            // Quick practice section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Quick Practice',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Random questions from all subjects',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickPracticeButton(
                              '5 Questions', Icons.looks_5),
                          const SizedBox(
                              width:
                                  20), // Adjust this width value to control the gap
                          _buildQuickPracticeButton(
                              '10 Questions', Icons.looks_one),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: _buildQuickPracticeButton(
                            '15 Questions', Icons.filter_1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                            value: item['progress'],
                            backgroundColor: Colors.grey[200],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(item['color']),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${item['completed']} / ${item['questions']} questions completed',
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

  Widget _buildQuickPracticeButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // Start quick practice
      },
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
