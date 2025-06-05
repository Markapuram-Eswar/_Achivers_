class Message {
  final String title;
  final String body;
  final String className;
  final String section;
  final List<String> students;
  final String recipientType;
  final DateTime timestamp;

  Message({
    required this.title,
    required this.body,
    required this.className,
    required this.section,
    required this.students,
    required this.recipientType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'class': className,
      'section': section,
      'students': students,
      'recipientType': recipientType,
      'timestamp': timestamp,
    };
  }
}
