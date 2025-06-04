import 'package:flutter/material.dart';
import 'widgets/progress_widgets.dart';
import 'data_service.dart';
import 'data_models.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReportsZonePage extends StatefulWidget {
  const ReportsZonePage({super.key});

  @override
  State<ReportsZonePage> createState() => _ReportsZonePageState();
}

class _ReportsZonePageState extends State<ReportsZonePage> {
  late Future<UserData> userDataFuture;
  String? selectedSubject;
  DateTimeRange? selectedDateRange;
  UserData? _originalData;
  UserData? _filteredData;

  @override
  void initState() {
    super.initState();
    // Properly initialize the Future
    userDataFuture = DataService().fetchUserData();

    // Load initial data
    userDataFuture.then((data) {
      if (mounted) {
        setState(() {
          _originalData = data;
          _filteredData = data;
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
      }
    });
  }

  void _onApplyFilters() {
    if (_originalData != null) {
      setState(() {
        _filteredData = _applyFilters(_originalData!);
      });
    }
  }

  void _onClearFilters() {
    setState(() {
      selectedSubject = null;
      selectedDateRange = null;
      _filteredData = _originalData;
    });
  }

  UserData _applyFilters(UserData original) {
    List<SubjectReport> filteredReports = original.reports;

    // Filter by subject
    if (selectedSubject != null && selectedSubject!.isNotEmpty) {
      filteredReports = filteredReports
          .where((r) => r.name.toLowerCase() == selectedSubject!.toLowerCase())
          .toList();
    }

    // Filter by date range
    if (selectedDateRange != null) {
      filteredReports = filteredReports.where((r) {
        final date = r.date;
        return date.isAfter(
                selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            date.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return UserData(
      user: original.user,
      learners: original.learners,
      reports: filteredReports,
      achievements: original.achievements,
      progressList: original.progressList,
      qaStats: original.qaStats,
      overviewItems: original.overviewItems,
    );
  }

  // Generate PDF of the filtered data
  Future<void> _generatePDF() async {
    if (_filteredData == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Learning Progress Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Filter Information
            if (selectedSubject != null || selectedDateRange != null) ...[
              pw.Text(
                'Applied Filters:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (selectedSubject != null)
                pw.Text('• Subject: $selectedSubject'),
              if (selectedDateRange != null)
                pw.Text(
                    '• Date Range: ${selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${selectedDateRange!.end.toLocal().toString().split(' ')[0]}'),
              pw.SizedBox(height: 20),
            ],

            // User Summary
            pw.Text(
              'Student Information',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Name: ${_filteredData!.user.name}'),
            pw.Text('XP Points: ${_filteredData!.user.xp}'),
            pw.Text('Badges: ${_filteredData!.user.badges}'),
            pw.Text('Rank: ${_filteredData!.user.rank}'),
            pw.SizedBox(height: 20),

            // Reports Summary
            pw.Text(
              'Subject Reports (${_filteredData!.reports.length} items)',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // Reports Table
            if (_filteredData!.reports.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Subject',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Percentage',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Date',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ..._filteredData!.reports
                      .map((report) => pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(report.name),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    '${report.percent.toStringAsFixed(1)}%'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(report.date
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                              ),
                            ],
                          ))
                      .toList(),
                ],
              )
            else
              pw.Text('No reports found for the selected filters.'),

            pw.SizedBox(height: 20),

            // Statistics
            pw.Text(
              'Statistics',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (_filteredData!.reports.isNotEmpty) ...[
              pw.Text('Total Reports: ${_filteredData!.reports.length}'),
              pw.Text(
                  'Average Percentage: ${(_filteredData!.reports.map((r) => r.percent).reduce((a, b) => a + b) / _filteredData!.reports.length).toStringAsFixed(1)}%'),
              pw.Text(
                  'Highest Percentage: ${_filteredData!.reports.map((r) => r.percent).fold(0.0, (prev, curr) => curr > prev ? curr : prev).toStringAsFixed(1)}%'),
              pw.Text(
                  'Lowest Percentage: ${_filteredData!.reports.map((r) => r.percent).fold(100.0, (prev, curr) => curr < prev ? curr : prev).toStringAsFixed(1)}%'),
            ],

            pw.SizedBox(height: 20),

            // Footer
            pw.Text(
              'Report generated on: ${DateTime.now().toLocal().toString().split('.')[0]}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ];
        },
      ),
    );

    // Show print preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'learning_progress_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Widget _buildSubjectDropdown(List<String> subjects) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        hint: const Text("Select Subject"),
        value: selectedSubject,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) {
          setState(() => selectedSubject = value);
        },
        items: ['All', ...subjects].map((subject) {
          return DropdownMenuItem(
            value: subject == 'All' ? null : subject,
            child: Text(subject),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(
        selectedDateRange == null
            ? "Select Date Range"
            : "${selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${selectedDateRange!.end.toLocal().toString().split(' ')[0]}",
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: selectedDateRange,
        );
        if (picked != null) {
          setState(() => selectedDateRange = picked);
        }
      },
    );
  }

  Widget _buildFilterControls(List<String> subjects) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSubjectDropdown(subjects),
            const SizedBox(height: 12),
            _buildDateRangePicker(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.filter_alt),
                    label: const Text("Apply Filters"),
                    onPressed: _onApplyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear"),
                    onPressed: _onClearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4285F4),
        centerTitle: true,
        title: const Text(
          'Reports',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications.")),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://img.icons8.com/isometric/50/appointment-reminders.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Menu not implemented.")),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://img.icons8.com/ios-filled/50/menu--v1.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<UserData>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading reports...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading data: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        userDataFuture = DataService().fetchUserData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final allData = snapshot.data!;
          final displayData = _filteredData ?? allData;
          final subjects = allData.reports.map((r) => r.name).toSet().toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Controls
                _buildFilterControls(subjects),
                const SizedBox(height: 16),

                // Results Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${displayData.reports.length} of ${allData.reports.length} reports',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (displayData.reports.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: _generatePDF,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text("Generate PDF"),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Components with filtered data
                UserSummary(user: displayData.user),
                const SizedBox(height: 16),
                TopLearners(learners: displayData.learners),
                const SizedBox(height: 16),
                ProgressReport(reports: displayData.reports),
                const SizedBox(height: 20),
                RecentAchievements(achievements: displayData.achievements),
                const SizedBox(height: 20),
                LearningProgress(progressList: displayData.progressList),
                const SizedBox(height: 20),
                QASummary(stats: displayData.qaStats),
                const SizedBox(height: 20),
                AchievementOverview(items: displayData.overviewItems),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: displayData.reports.isNotEmpty
                            ? _generatePDF
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Download Report"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Open progress chart or dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Progress chart feature coming soon!")),
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text("Show Progress"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }
}
