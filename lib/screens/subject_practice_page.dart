import 'package:flutter/material.dart';
import 'mcq_page.dart';
import 'fillups_page.dart';
import 'textbook_page.dart';

class SubjectPracticePage extends StatefulWidget {
  final Map<String, dynamic> subjectData;

  const SubjectPracticePage({super.key, required this.subjectData});

  @override
  SubjectPracticePageState createState() => SubjectPracticePageState();
}

class SubjectPracticePageState extends State<SubjectPracticePage> {
  late List<Map<String, dynamic>> _topicsList;

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch subject practice data from backend (API call, database read) */
    // Initialize topics based on the subject
    _initializeTopics();
  }

  void _initializeTopics() {
    // This would ideally come from a database or API
    // For now, we'll create sample data based on the subject
    switch (widget.subjectData['title']) {
      case 'Mathematics':
        _topicsList = [
          {
            'title': 'Algebra',
            'questions': 40,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/formula-fx.png',
          },
          {
            'title': 'Geometry',
            'questions': 35,
            'difficulty': 'Hard',
            'icon': 'https://img.icons8.com/isometric/50/trigonometry.png',
          },
          {
            'title': 'Calculus',
            'questions': 30,
            'difficulty': 'Advanced',
            'icon': 'https://img.icons8.com/isometric/50/sigma.png',
          },
          {
            'title': 'Statistics',
            'questions': 25,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/combo-chart.png',
          },
        ];
        break;
      case 'Science':
        _topicsList = [
          {
            'title': 'Physics',
            'questions': 45,
            'difficulty': 'Hard',
            'icon': 'https://img.icons8.com/isometric/50/physics.png',
          },
          {
            'title': 'Chemistry',
            'questions': 40,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/test-tube.png',
          },
          {
            'title': 'Biology',
            'questions': 35,
            'difficulty': 'Easy',
            'icon': 'https://img.icons8.com/isometric/50/dna-helix.png',
          },
          {
            'title': 'Earth Science',
            'questions': 30,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/globe.png',
          },
        ];
        break;
      case 'English':
        _topicsList = [
          {
            'title': 'Grammar',
            'questions': 50,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/grammar.png',
          },
          {
            'title': 'Vocabulary',
            'questions': 40,
            'difficulty': 'Easy',
            'icon': 'https://img.icons8.com/isometric/50/dictionary.png',
          },
          {
            'title': 'Literature',
            'questions': 30,
            'difficulty': 'Hard',
            'icon': 'https://img.icons8.com/isometric/50/literature.png',
          },
          {
            'title': 'Comprehension',
            'questions': 25,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/reading.png',
          },
        ];
        break;
      case 'Social Studies':
        _topicsList = [
          {
            'title': 'History',
            'questions': 45,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/historical.png',
          },
          {
            'title': 'Geography',
            'questions': 40,
            'difficulty': 'Easy',
            'icon': 'https://img.icons8.com/isometric/50/globe.png',
          },
          {
            'title': 'Civics',
            'questions': 30,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/scales.png',
          },
          {
            'title': 'Economics',
            'questions': 25,
            'difficulty': 'Hard',
            'icon': 'https://img.icons8.com/isometric/50/economic-growth.png',
          },
        ];
        break;
      case 'Telugu':
        _topicsList = [
          {
            'title': 'Grammar',
            'questions': 35,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/grammar.png',
          },
          {
            'title': 'Literature',
            'questions': 30,
            'difficulty': 'Hard',
            'icon': 'https://img.icons8.com/isometric/50/literature.png',
          },
          {
            'title': 'Comprehension',
            'questions': 25,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/reading.png',
          },
          {
            'title': 'Poetry',
            'questions': 20,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/quill-pen.png',
          },
        ];
        break;
      case 'Hindi':
        _topicsList = [
          {
            'title': 'Grammar',
            'questions': 40,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/grammar.png',
          },
          {
            'title': 'Literature',
            'questions': 30,
            'difficulty': 'Hard',
            'icon': 'https://img.icons8.com/isometric/50/literature.png',
          },
          {
            'title': 'Vocabulary',
            'questions': 25,
            'difficulty': 'Easy',
            'icon': 'https://img.icons8.com/isometric/50/dictionary.png',
          },
          {
            'title': 'Writing',
            'questions': 20,
            'difficulty': 'Medium',
            'icon': 'https://img.icons8.com/isometric/50/edit.png',
          },
        ];
        break;
      default:
        _topicsList = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subjectData['title']} Practice',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.subjectData['color'],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Add a help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add a navigation header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: widget.subjectData['color'].withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.book,
                  color: widget.subjectData['color'],
                ),
                const SizedBox(width: 8),
                Text(
                  'Select a topic to practice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.subjectData['color'],
                  ),
                ),
              ],
            ),
          ),
          // Topics list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _topicsList.length,
              itemBuilder: (context, index) {
                final topic = _topicsList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      _showPracticeOptions(context, topic);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Topic icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color:
                                  widget.subjectData['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.network(
                              topic['icon'],
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Topic details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${topic['questions']} questions • ${topic['difficulty']} difficulty',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Navigation arrow
                          Icon(
                            Icons.arrow_forward_ios,
                            color: widget.subjectData['color'],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom navigation bar has been removed
    );
  }

  void _showPracticeOptions(BuildContext context, Map<String, dynamic> topic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Practice ${topic['title']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Practice options
              ListTile(
                leading: Icon(Icons.quiz, color: widget.subjectData['color']),
                title: const Text('Multiple Choice Questions'),
                subtitle: const Text('Test your knowledge with MCQs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => McqPage(
                        subjectData: widget.subjectData,
                        topicData: topic,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: widget.subjectData['color']),
                title: const Text('Fill in the Blanks'),
                subtitle: const Text('Complete sentences with missing words'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FillupsPage(
                        subjectData: widget.subjectData,
                        topicData: topic,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.menu_book, color: widget.subjectData['color']),
                title: const Text('Read Textbook'),
                subtitle: const Text('Study the topic in detail'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextbookPage(
                        subjectData: widget.subjectData,
                        topicData: topic,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Guide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Select a topic from the list'),
            SizedBox(height: 8),
            Text('2. Choose a practice type (MCQ, Fill-ups, or Textbook)'),
            SizedBox(height: 8),
            Text('3. Complete the exercises to improve your knowledge'),
            SizedBox(height: 8),
            Text('4. Track your progress in the Progress Zone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
