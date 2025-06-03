import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> _taskItems = [
    {
      'title': 'Mathematics',
      'subtitle': 'Algebra, Geometry, Calculus',
      'icon': 'https://img.icons8.com/isometric/50/calculator.png',
      'color': Colors.blue,
      'progress': 0.65,
      'tasks': 15,
      'completed': 10,
    },
    {
      'title': 'Science',
      'subtitle': 'Physics, Chemistry, Biology',
      'icon': 'https://img.icons8.com/isometric/50/test-tube.png',
      'color': Colors.green,
      'progress': 0.40,
      'tasks': 20,
      'completed': 8,
    },
    {
      'title': 'English',
      'subtitle': 'Grammar, Vocabulary, Literature',
      'icon': 'https://img.icons8.com/isometric/50/literature.png',
      'color': Colors.purple,
      'progress': 0.75,
      'tasks': 12,
      'completed': 9,
    },
    {
      'title': 'History',
      'subtitle': 'World History, Civics, Geography',
      'icon': 'https://img.icons8.com/isometric/50/globe.png',
      'color': Colors.orange,
      'progress': 0.30,
      'tasks': 10,
      'completed': 3,
    },
  ];

  final List<Map<String, dynamic>> _recentTasks = [
    {
      'title': 'Algebra Homework',
      'subject': 'Mathematics',
      'dueDate': 'Due Tomorrow',
      'status': 'In Progress',
      'color': Colors.blue,
    },
    {
      'title': 'Science Project',
      'subject': 'Science',
      'dueDate': 'Due in 2 days',
      'status': 'Not Started',
      'color': Colors.green,
    },
    {
      'title': 'Book Report',
      'subject': 'English',
      'dueDate': 'Due in 3 days',
      'status': 'Not Started',
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch tasks from backend (API call, database read) */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Tasks', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32, // Account for padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header section
                    const Text(
                      'Your Tasks Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track and manage your academic tasks',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upcoming tasks section
                    const Text(
                      'Upcoming Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160, // Slightly increased height
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentTasks.take(2).length,
                        itemExtent: 220, // Fixed width for each item
                        itemBuilder: (context, index) {
                          final item = _recentTasks[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: item['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: item['color'].withOpacity(0.3)),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['dueDate'],
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
                                        item['status'],
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

                    // All subjects section
                    const Text(
                      'Tasks by Subject',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1, // Slightly reduced aspect ratio
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 180, // Fixed height for each grid item
                      ),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      itemCount: _taskItems.length,
                      itemBuilder: (context, index) {
                        final item = _taskItems[index];
                        return _buildTaskCard(item, context);
                      },
                    ),
                  ],
                ),
              )),
        ));
  }

  // Helper function to handle long text with ellipsis
  Widget _buildTextWithEllipsis(String text, TextStyle style,
      {int maxLines = 1}) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> item, BuildContext context) {
    void _navigateToSubject(Map<String, dynamic> subject) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetailScreen(subject: subject['title']),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _navigateToSubject(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: item['progress'],
              backgroundColor: item['color'].withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(item['color']),
              minHeight: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          item['icon'],
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextWithEllipsis(
                          item['title'],
                          const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress text
                  _buildTextWithEllipsis(
                    '${item['completed']} of ${item['tasks']} tasks',
                    const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      height: 1.2,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  // Progress percentage
                  Text(
                    '${(item['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: item['color'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // View all button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: item['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Task detail screen that shows tasks for the selected subject
class TaskDetailScreen extends StatefulWidget {
  final String subject;

  const TaskDetailScreen({super.key, required this.subject});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample task data - in a real app, this would come from an API or database
  final List<Map<String, dynamic>> _upcomingTasks = [];
  final List<Map<String, dynamic>> _currentTasks = [];
  final List<Map<String, dynamic>> _pastTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  void _loadTasks() {
    // Sample tasks for each subject
    final now = DateTime.now();

    // Sample data - in a real app, this would come from an API or database
    final allTasks = [
      {
        'title': '${widget.subject} Homework',
        'description': 'Complete exercises 1-10 from chapter 5',
        'dueDate': now.add(const Duration(days: 2)),
        'completed': false,
      },
      {
        'title': '${widget.subject} Project',
        'description': 'Work on the group project presentation',
        'dueDate': now.add(const Duration(days: 5)),
        'completed': false,
      },
      {
        'title': '${widget.subject} Quiz',
        'description': 'Chapter 4-5 quiz',
        'dueDate': now.subtract(const Duration(days: 2)),
        'completed': true,
      },
      {
        'title': '${widget.subject} Reading',
        'description': 'Read pages 45-60',
        'dueDate': now.add(const Duration(hours: 2)),
        'completed': false,
      },
      {
        'title': '${widget.subject} Worksheet',
        'description': 'Complete the practice problems',
        'dueDate': now.subtract(const Duration(days: 1)),
        'completed': true,
      },
    ];

    // Categorize tasks
    for (var task in allTasks) {
      final dueDate = task['dueDate'] as DateTime;
      final isPast = dueDate.isBefore(now.subtract(const Duration(hours: 1)));
      final isCurrent = dueDate.isAfter(now) &&
          dueDate.isBefore(now.add(const Duration(days: 1)));

      if (isPast) {
        _pastTasks.add(task);
      } else if (isCurrent) {
        _currentTasks.add(task);
      } else {
        _upcomingTasks.add(task);
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${_getWeekday(date.weekday)} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  Color _getTaskColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (dueDate.isBefore(now)) {
      return Colors.red.shade100; // Past due
    } else if (difference.inHours < 24) {
      return Colors.orange.shade100; // Due today
    } else if (difference.inDays < 3) {
      return Colors.blue.shade100; // Due in 1-2 days
    } else {
      return Colors.green.shade100; // Due later
    }
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks,
      {bool showCompleted = false}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks here yet!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your free time!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final dueDate = task['dueDate'] as DateTime;
        final isCompleted = task['completed'] as bool? ?? false;

        return Dismissible(
          key: Key('task_${task['title']}_$index'),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            setState(() {
              tasks.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task "${task['title']}" removed'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    setState(() {
                      tasks.insert(index, task);
                    });
                  },
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  isCompleted ? Colors.grey.shade100 : _getTaskColor(dueDate),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Handle task tap (e.g., show details)
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12, top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? Colors.green
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.green,
                              )
                            : null,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color:
                                    isCompleted ? Colors.grey : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (task['description'] != null &&
                                task['description'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  task['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(dueDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!isCompleted)
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          color: Colors.grey.shade600,
                          onPressed: () {
                            // Show task options
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '${widget.subject} Tasks',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.shade500.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicator: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(30),
              ),
              tabs: const [
                Tab(text: 'Current'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(_currentTasks),
            _buildTaskList(_upcomingTasks),
            _buildTaskList(_pastTasks, showCompleted: true),
          ],
        ),
      ),
    );
  }
}
