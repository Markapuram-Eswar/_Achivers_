import 'package:flutter/material.dart';

class TakeAttendanceScreen extends StatefulWidget {
  const TakeAttendanceScreen({super.key});

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final Map<String, bool> _attendance = {
    'Eswar Kumar': false,
    'Aditi Sharma': false,
    'Arjun Patel': false,
    'Diya Singh': false,
    'Praveen Kumar': false,
    'Arjun Reddy': false,
    'Kavya Gupta': false,
    'Krishna Rao': false,
    'Meera': false,
    'Nikhil': false,
    'Priya': false,
    'Rahul': false,
    'Riya Desai': false,
    'Sai Prasad': false,
    'Shreyas': false,
  };

  DateTime _selectedDate = DateTime.now();
  String? _selectedClass;
  String? _selectedSection;

  final List<String> _classes = [
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10'
  ];
  final List<String> _sections = ['A', 'B', 'C', 'D'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch attendance data from backend (API call, database read) */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Take Attendance',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Grade 8 - A | Mathematics',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter section with improved layout
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // First row: Class and Section dropdowns
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('Select Class'),
                          value: _selectedClass,
                          items: _classes
                              .map((grade) => DropdownMenuItem(
                                    value: grade,
                                    child: Text(grade),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClass = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('Select Section'),
                          value: _selectedSection,
                          items: _sections
                              .map((section) => DropdownMenuItem(
                                    value: section,
                                    child: Text(section),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSection = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row: Date picker and student count
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'February ${_selectedDate.day}, ${_selectedDate.year}',
                              ),
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.blue[700]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_attendance.length} Students',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mark All Present Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            margin: const EdgeInsets.only(top: 1), // Small divider
            child: Row(
              children: [
                Text(
                  'Mark All Present',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _attendance.values.every((v) => v),
                  activeColor: Colors.blue[700],
                  onChanged: (bool value) {
                    setState(() {
                      for (var key in _attendance.keys) {
                        _attendance[key] = value;
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _attendance.length,
              itemBuilder: (context, index) {
                final name = _attendance.keys.elementAt(index);
                final isPresent = _attendance[name]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          isPresent ? Colors.green[50] : Colors.grey[100],
                      child: Text(
                        name.split(' ')[0][0],
                        style: TextStyle(
                          color:
                              isPresent ? Colors.green[700] : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Roll No. ${index + 1}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _attendance[name] = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPresent ? Colors.green : Colors.grey[200],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Present',
                            style: TextStyle(
                              color:
                                  isPresent ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _attendance[name] = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !isPresent ? Colors.red : Colors.grey[200],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Absent',
                            style: TextStyle(
                              color:
                                  !isPresent ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Submit Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _submitAttendance,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAttendance() async {
    /* Backend TODO: Submit attendance to backend (API call, database write) */
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
