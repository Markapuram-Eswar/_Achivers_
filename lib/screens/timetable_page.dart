import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key});

  @override
  AttendanceCalendarPageState createState() => AttendanceCalendarPageState();
}

class AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, Map<String, String>> _attendanceStatus = {};
  bool _isLoading = true;
  double _attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final data = await fetchAttendanceFromBackend();
      final presentDays =
          data.values.where((v) => v['status'] == 'Present').length;
      final totalDays =
          data.values.where((v) => v['status'] != 'Holiday').length;

      setState(() {
        _attendanceStatus = data;
        _attendancePercentage = (presentDays / totalDays) * 100;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (kDebugMode) {
        print("Error fetching attendance: $e");
      }
    }
  }

  Future<Map<DateTime, Map<String, String>>>
      fetchAttendanceFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));

    final response = jsonEncode([
      {"date": "2025-05-01", "status": "Present"},
      {"date": "2025-05-02", "status": "Absent"},
      {"date": "2025-05-03", "status": "Holiday", "reason": "Good Friday"},
      {"date": "2025-05-23", "status": "Holiday", "reason": "Founders' Day"},
      {"date": "2025-05-04", "status": "Present"},
      {"date": "2025-05-05", "status": "Absent"},
    ]);

    final List<dynamic> decoded = json.decode(response);
    final Map<DateTime, Map<String, String>> result = {};

    for (var item in decoded) {
      final dateParts = item['date'].split('-').map(int.parse).toList();
      final date = DateTime.utc(dateParts[0], dateParts[1], dateParts[2]);
      result[date] = {
        'status': item['status'],
        'reason': item['reason'] ?? '',
      };
    }

    return result;
  }

  Color _getStatusColor(DateTime date) {
    final data =
        _attendanceStatus[DateTime.utc(date.year, date.month, date.day)];
    switch (data?['status']) {
      case 'Present':
        return Colors.green.shade400;
      case 'Absent':
        return Colors.red.shade400;
      case 'Holiday':
        return Colors.blue.shade400;
      default:
        return Colors.transparent;
    }
  }

  List<Widget> _buildHolidayList() {
    final holidays = _attendanceStatus.entries
        .where((entry) => entry.value['status'] == 'Holiday')
        .map((entry) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: Icon(Icons.event, color: Colors.blue.shade400),
                title: Text(
                  '${entry.key.toLocal()}'.split(' ')[0],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  entry.value['reason']?.isNotEmpty == true
                      ? entry.value['reason']!
                      : 'Holiday',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ))
        .toList();
    return holidays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('My Attendance', style: GoogleFonts.poppins()),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.blue.shade800, Colors.blue.shade500],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_attendancePercentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Attendance Rate',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Colors.blue.shade300,
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              headerStyle: HeaderStyle(
                                titleTextStyle: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                                formatButtonTextStyle: GoogleFonts.poppins(),
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                              calendarFormat: CalendarFormat.month,
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, date, _) {
                                  final color = _getStatusColor(date);
                                  return Container(
                                    margin: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${date.day}',
                                      style: GoogleFonts.poppins(
                                        color: color == Colors.transparent
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ).animate().fadeIn().slideY(),
                        const SizedBox(height: 20),
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
                                  'Status Legend',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const LegendRow(),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().slideY(delay: 200.ms),
                        const SizedBox(height: 20),
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
                                  'Upcoming Holidays',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._buildHolidayList(),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().slideY(delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class LegendRow extends StatelessWidget {
  const LegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LegendItem(color: Colors.green.shade400, label: 'Present'),
        LegendItem(color: Colors.red.shade400, label: 'Absent'),
        LegendItem(color: Colors.blue.shade400, label: 'Holiday'),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }
}
