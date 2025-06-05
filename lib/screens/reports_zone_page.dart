import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/progress_widgets.dart';
import 'data_service.dart';
import 'data_models.dart';
import 'progress_page.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';

void main() {
  runApp(MaterialApp(
    home: ReportsZonePage(),
  ));
}

class ReportsZonePage extends StatefulWidget {
  const ReportsZonePage({super.key});

  @override
  State<ReportsZonePage> createState() => _ReportsZonePageState();
}

class _ReportsZonePageState extends State<ReportsZonePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Future<UserData> userDataFuture = DataService().fetchUserData();

  // Sample data for academic performance
  final List<Map<String, String>> _sampleTable = [
    {'Subject': 'Mathematics', 'Marks': '45', 'MaxMarks': '50', 'Grade': 'A'},
    {'Subject': 'Science', 'Marks': '42', 'MaxMarks': '50', 'Grade': 'B+'},
    {'Subject': 'English', 'Marks': '48', 'MaxMarks': '50', 'Grade': 'A+'},
    {
      'Subject': 'Social Studies',
      'Marks': '40',
      'MaxMarks': '50',
      'Grade': 'B'
    },
    {'Subject': 'Hindi', 'Marks': '44', 'MaxMarks': '50', 'Grade': 'A'},
  ];

  String? _selectedClass;
  String? _selectedTest;
  String? _selectedZoneType;
  String? _selectedDateRange;

  final List<String> _classes = ['7', '8', '9', '10'];
  final List<String> _tests = ['FA1', 'FA2', 'SA1', 'FA3', 'FA4', 'SA2'];
  final List<String> _zoneTypes = ['All Zones', 'Test Zone', 'Practice Zone', 'Doubts'];
  final List<String> _dateRanges = ['All Time', 'Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Month', 'Last Month'];

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

  Future<void> _downloadAppReportPdf() async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Generating app report...'),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final formattedDate = '${now.day}/${now.month}/${now.year}';

      // Add a page to the PDF
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
                  'App Usage Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Report Format
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue900, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Report Details',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildReportRow('Zone Type', _selectedZoneType ?? 'All Zones'),
                    _buildReportRow('Date Range', _selectedDateRange ?? 'All Time'),
                    _buildReportRow('Generated On', formattedDate),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Report Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Generated on: $formattedDate'),
                      pw.Text('App Version: 1.0.0'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Summary Section
              pw.Header(
                level: 1,
                child: pw.Text(
                  'App Usage Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildReportRow('Total Time Spent', '12h 45m'),
                    _buildReportRow('Lessons Completed', '24'),
                    _buildReportRow('Quizzes Taken', '15'),
                    _buildReportRow('Average Score', '87%'),
                    _buildReportRow('Streak Days', '7'),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Save the PDF to a temporary file
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/app_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Hide the loading snackbar
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
      }

      // Open the PDF file
      await OpenFilex.open(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildReportRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadSampleTablePdf() async {
    // Show loading indicator
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Generating report...'),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final formattedDate = '${now.day}/${now.month}/${now.year}';

      // Calculate total marks and percentage
      final totalMarks = _sampleTable.fold<int>(
          0, (sum, item) => sum + int.parse(item['Marks']!));
      final maxMarks = _sampleTable.fold<int>(
          0, (sum, item) => sum + int.parse(item['MaxMarks']!));
      final percentage = (totalMarks / maxMarks * 100).toStringAsFixed(1);

      // Add a page to the PDF
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
                  'Academic Performance Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // Report Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student Name: [Student Name]'),
                      pw.Text('Class: ${_selectedClass ?? "Not Selected"}'),
                      pw.Text('Test: ${_selectedTest ?? "Not Selected"}'),
                    ],
                  ),
                  pw.Text('Date: $formattedDate'),
                ],
              ),
              pw.SizedBox(height: 24),

              // Summary Card
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Performance Summary',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Marks: $totalMarks / $maxMarks'),
                        pw.Text('Percentage: $percentage%'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Subject-wise Performance
              pw.Text(
                'Subject-wise Performance',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Subject',
                  'Marks Obtained',
                  'Max Marks',
                  'Grade',
                  'Performance'
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
                data: _sampleTable.map((row) {
                  final marks = int.parse(row['Marks']!);
                  final max = int.parse(row['MaxMarks']!);
                  final percentage = (marks / max * 100);
                  String performance;

                  if (percentage >= 85) {
                    performance = 'Excellent';
                  } else if (percentage >= 70) {
                    performance = 'Good';
                  } else if (percentage >= 55) {
                    performance = 'Average';
                  } else {
                    performance = 'Needs Improvement';
                  }

                  return [
                    row['Subject'],
                    row['Marks'],
                    row['MaxMarks'],
                    row['Grade'],
                    performance,
                  ];
                }).toList(),
                cellStyle: const pw.TextStyle(fontSize: 12),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 1,
                ),
                headerPadding: const pw.EdgeInsets.all(8),
                cellPadding: const pw.EdgeInsets.all(8),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.grey200,
                      width: 1,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // Footer
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Generated by School App - $formattedDate',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save the PDF
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/academic_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        // Hide loading
        scaffoldMessenger.hideCurrentSnackBar();

        // Show success message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Report generated successfully!',
                    style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(file.path),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // Open the PDF
      await OpenFilex.open(file.path);

      // Optionally, share the file
      // await Share.shareFiles([file.path], text: 'My Academic Report');
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error generating report: ${e.toString()}',
                    style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.blue[50]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Academic Reports',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.blue[900],
                  indicatorWeight: 3,
                  labelColor: Colors.blue[900],
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Campus Reports'),
                    Tab(text: 'App Reports'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Performance Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Academic Performance',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              DropdownButtonFormField<String>(
                                            value: _selectedClass,
                                            items: _classes
                                                .map((c) => DropdownMenuItem(
                                                      value: c,
                                                      child: Text(c,
                                                          style: GoogleFonts
                                                              .poppins()),
                                                    ))
                                                .toList(),
                                            onChanged: (val) => setState(
                                                () => _selectedClass = val),
                                            decoration: InputDecoration(
                                              labelText: 'Class',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child:
                                              DropdownButtonFormField<String>(
                                            value: _selectedTest,
                                            items: _tests
                                                .map((t) => DropdownMenuItem(
                                                      value: t,
                                                      child: Text(t,
                                                          style: GoogleFonts
                                                              .poppins()),
                                                    ))
                                                .toList(),
                                            onChanged: (val) => setState(
                                                () => _selectedTest = val),
                                            decoration: InputDecoration(
                                              labelText: 'Exam',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().slideY(),
                            const SizedBox(height: 24),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subject Wise Performance',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.info_outline),
                                          onPressed: () {
                                            // Show info dialog
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) =>
                                              Colors.blue[50],
                                        ),
                                        columnSpacing: 28,
                                        horizontalMargin: 12,
                                        columns: [
                                          DataColumn(
                                            label: Text('Subject',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Marks',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            numeric: true,
                                          ),
                                          DataColumn(
                                            label: Text('Max',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            numeric: true,
                                          ),
                                          DataColumn(
                                            label: Text('Grade',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                        rows: _sampleTable.map((row) {
                                          final grade = row['Grade']!;
                                          final color = grade.startsWith('A')
                                              ? Colors.green
                                              : grade.startsWith('B')
                                                  ? Colors.blue
                                                  : Colors.orange;

                                          return DataRow(
                                            cells: [
                                              DataCell(Text(row['Subject']!,
                                                  style:
                                                      GoogleFonts.poppins())),
                                              DataCell(Text(row['Marks']!,
                                                  style:
                                                      GoogleFonts.poppins())),
                                              DataCell(Text(row['MaxMarks']!,
                                                  style:
                                                      GoogleFonts.poppins())),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        color.withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    grade,
                                                    style: GoogleFonts.poppins(
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().slideY(
                                delay: const Duration(milliseconds: 200)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _downloadSampleTablePdf,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900],
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.download),
                                    label: Text(
                                      "Download Report",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProgressPage()),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      side:
                                          BorderSide(color: Colors.blue[900]!),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.bar_chart),
                                    label: Text(
                                      "View Progress",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn().slideY(
                                delay: const Duration(milliseconds: 400)),
                          ],
                        ),
                      ),

                      // Progress Tab
                      FutureBuilder<UserData>(
                        future: userDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.network(
                                    'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json',
                                    width: 200,
                                    height: 200,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading your progress...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 64, color: Colors.red[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading data',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                  Text(
                                    'Please try again later',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData) {
                            return Center(
                              child: Text(
                                'No data available',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            );
                          }

                          final data = snapshot.data!;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header and Download Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'App Usage Report',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _downloadAppReportPdf,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[900],
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.download, size: 20),
                                      label: Text(
                                        'Download Report',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Filter Options Card
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Filter Options',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: _selectedZoneType ?? _zoneTypes.first,
                                                items: _zoneTypes
                                                    .map((type) => DropdownMenuItem(
                                                          value: type,
                                                          child: Text(type,
                                                              style: GoogleFonts.poppins()),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) => setState(
                                                    () => _selectedZoneType = val),
                                                decoration: InputDecoration(
                                                  labelText: 'Zone Type',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 16),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: _selectedDateRange ?? _dateRanges.first,
                                                items: _dateRanges
                                                    .map((range) => DropdownMenuItem(
                                                          value: range,
                                                          child: Text(range,
                                                              style: GoogleFonts.poppins()),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) => setState(
                                                    () => _selectedDateRange = val),
                                                decoration: InputDecoration(
                                                  labelText: 'Date Range',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                UserSummary(user: data.user),
                                const SizedBox(height: 16),
                                TopLearners(learners: data.learners),
                                const SizedBox(height: 16),
                                ProgressReport(reports: data.reports),
                                const SizedBox(height: 16),
                                RecentAchievements(
                                    achievements: data.achievements),
                                const SizedBox(height: 16),
                                LearningProgress(
                                    progressList: data.progressList),
                                const SizedBox(height: 16),
                                QASummary(stats: data.qaStats),
                                const SizedBox(height: 16),
                                AchievementOverview(items: data.overviewItems),
                              ]
                                  .animate(
                                      interval:
                                          const Duration(milliseconds: 100))
                                  .fadeIn()
                                  .slideY(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
