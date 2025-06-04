import 'package:flutter/material.dart';
import 'widgets/progress_widgets.dart';
import 'data_service.dart';
import 'data_models.dart';
import 'progress_page.dart';

void main() {
  runApp(MaterialApp(
    home: ReportsZonePage(),
  ));
}

class ReportsZonePage extends StatefulWidget {
  ReportsZonePage({super.key});

  @override
  State<ReportsZonePage> createState() => _ReportsZonePageState();
}

class _ReportsZonePageState extends State<ReportsZonePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Future<UserData> userDataFuture = DataService().fetchUserData();

  // Sample data for Req IP table
  final List<Map<String, String>> _sampleTable = [
    {'Subject': 'Mathematics', 'Marks': '45', 'MaxMarks': '50', 'Grade': 'A'},
    {'Subject': 'Science', 'Marks': '42', 'MaxMarks': '50', 'Grade': 'B+'},
    {'Subject': 'English', 'Marks': '48', 'MaxMarks': '50', 'Grade': 'A+'},
    {'Subject': 'Social', 'Marks': '40', 'MaxMarks': '50', 'Grade': 'B'},
    {'Subject': 'Hindi', 'Marks': '44', 'MaxMarks': '50', 'Grade': 'A'},
  ];

  String? _selectedClass;
  String? _selectedTest;

  final List<String> _classes = ['7', '8', '9', '9'];
  final List<String> _tests = ['FA1', 'FA2', 'SA'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedClass = _classes.first;
    _selectedTest = _tests.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        elevation: 1,
        title: const Text(
          'Reports',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blueAccent, // or any accent color you like
              indicatorWeight: 3,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'App Reports'),
                Tab(text: 'Campus Reports'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Screen 1: Summary ---
          FutureBuilder<UserData>(
            future: userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error loading data: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available.'));
              }

              final data = snapshot.data!;
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    UserSummary(user: data.user),
                    const SizedBox(height: 16),
                    TopLearners(learners: data.learners),
                    const SizedBox(height: 16),
                    ProgressReport(reports: data.reports),
                    const SizedBox(height: 20),
                    RecentAchievements(achievements: data.achievements),
                    const SizedBox(height: 20),
                    LearningProgress(progressList: data.progressList),
                    const SizedBox(height: 20),
                    QASummary(stats: data.qaStats),
                    const SizedBox(height: 20),
                    AchievementOverview(items: data.overviewItems),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Download Report"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProgressPage(), // <-- Replace with your ProgressPage widget
                              ),
                            );
                          },
                          icon: const Icon(Icons.bar_chart),
                          label: const Text("Show Progress"),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
          // --- Screen 2: Req IP ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Request Individual Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        items: _classes
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedClass = val);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTest,
                        items: _tests
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedTest = val);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Test',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sample Table',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) => Colors.grey[200],
                        ),
                        columnSpacing: 28,
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.grey[200]!),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('Subject',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Marks',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Max Marks',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Grade',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: _sampleTable
                            .map(
                              (row) => DataRow(
                                cells: [
                                  DataCell(Text(row['Subject']!)),
                                  DataCell(Text(row['Marks']!)),
                                  DataCell(Text(row['MaxMarks']!)),
                                  DataCell(Text(row['Grade']!)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
