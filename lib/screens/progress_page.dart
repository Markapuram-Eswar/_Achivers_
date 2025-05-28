import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressZonePageState();
}

class _ProgressZonePageState extends State<ProgressPage> {
  // Sample progress data
  final List<Map<String, dynamic>> _progressData = [
    {
      'subject': 'Mathematics',
      'progress': 0.75,
      'color': Colors.blue,
      'icon': 'https://img.icons8.com/isometric/50/hygrometer.png',
    },
    {
      'subject': 'Science',
      'progress': 0.60,
      'color': Colors.green,
      'icon': 'https://img.icons8.com/isometric/50/microscope.png',
    },
    {
      'subject': 'English',
      'progress': 0.85,
      'color': Colors.purple,
      'icon': 'https://img.icons8.com/isometric/50/book-shelf.png',
    },
    {
      'subject': 'Social Studies',
      'progress': 0.45,
      'color': Colors.orange,
      'icon': 'https://img.icons8.com/isometric/50/world-map.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch progress data from backend (API call, database read) */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Progress Zone', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Learning Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your progress across different subjects',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Progress cards
            ..._progressData.map((data) => _buildProgressCard(data)),

            const SizedBox(height: 24),

            // Overall progress section
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '65% Completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        'Target: 100%',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Achievements section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
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
                      Icon(Icons.emoji_events, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Recent Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAchievementBadge(
                          'Quiz Master', '5 quizzes completed'),
                      _buildAchievementBadge('Fast Learner', '3 days streak'),
                      _buildAchievementBadge(
                          'Perfect Score', '100% in Science'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to a detailed achievements page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: Center(
                                  child: Text(
                                      'Achievements Detail Page Coming Soon'),
                                ),
                              ),
                            ),
                          );
                        },
                        icon:
                            const Icon(Icons.emoji_events, color: Colors.amber),
                        label: const Text('View All Achievements'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.amber,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to practice page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: Center(
                                  child: Text('Practice Page Coming Soon'),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay, color: Colors.white),
                        label: const Text('Practice Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Remove the horizontal scrollable list and additional badges
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: data['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              data['icon'],
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
                  data['subject'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: data['progress'],
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(data['color']),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(data['progress'] * 100).toInt()}% Completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: data['color'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.star,
            color: Colors.amber,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
