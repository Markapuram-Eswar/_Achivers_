import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    /* Backend TODO: Fetch timetable data from backend (API call, database read) */
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final data = await fetchAttendanceFromBackend();
      setState(() {
        _attendanceStatus = data;
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
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Holiday':
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }

  List<Widget> _buildHolidayList() {
    final holidays = _attendanceStatus.entries
        .where((entry) => entry.value['status'] == 'Holiday')
        .map((entry) => ListTile(
              title: Text(
                '${entry.key.toLocal()}'.split(' ')[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(entry.value['reason']?.isNotEmpty == true
                  ? entry.value['reason']!
                  : 'Holiday'),
            ))
        .toList();
    return holidays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(12),
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
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
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
                                style: TextStyle(
                                  color: color == Colors.transparent
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const LegendRow(),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'List of Holidays:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(8),
                      height: 300,
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _buildHolidayList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class LegendRow extends StatelessWidget {
  const LegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LegendItem(color: Colors.green, label: 'Present'),
          LegendItem(color: Colors.red, label: 'Absent'),
          LegendItem(color: Colors.blue, label: 'Holiday'),
        ],
      ),
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
        Text(label),
      ],
    );
  }
}
