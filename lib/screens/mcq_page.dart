import 'package:flutter/material.dart';

class McqPage extends StatefulWidget {
  final Map<String, dynamic> subjectData;
  final Map<String, dynamic> topicData;

  const McqPage({
    super.key,
    required this.subjectData,
    required this.topicData,
  });

  @override
  McqPageState createState() => McqPageState();
}

class McqPageState extends State<McqPage> {
  late List<Map<String, dynamic>> _questions;
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  bool _hasSubmitted = false;
  bool _showReview = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    // Sample questions - in a real app, this would come from a database
    _questions = [
      {
        'question':
            'Which of the following best describes ${widget.topicData['title']}?',
        'options': [
          'The study of numbers and their operations',
          'The study of matter and energy',
          'The study of living organisms',
          'The study of language and communication'
        ],
        'correctAnswer': 0,
        'explanation':
            'This is the fundamental definition of ${widget.topicData['title']} in ${widget.subjectData['title']}.'
      },
      {
        'question':
            'Who is considered the father of modern ${widget.topicData['title']}?',
        'options': [
          'Albert Einstein',
          'Isaac Newton',
          'Galileo Galilei',
          'Nikola Tesla'
        ],
        'correctAnswer': 1,
        'explanation':
            'Isaac Newton made significant contributions to the field of ${widget.topicData['title']} and is often considered its founding father.'
      },
      {
        'question':
            'Which principle is NOT associated with ${widget.topicData['title']}?',
        'options': [
          'Conservation of energy',
          'Law of gravity',
          'Principle of relativity',
          'Law of diminishing returns'
        ],
        'correctAnswer': 3,
        'explanation':
            'The law of diminishing returns is an economic principle, not related to ${widget.topicData['title']}.'
      },
      {
        'question':
            'What is the primary application of ${widget.topicData['title']} in modern technology?',
        'options': [
          'Social media algorithms',
          'Renewable energy systems',
          'Medical diagnostics',
          'All of the above'
        ],
        'correctAnswer': 3,
        'explanation':
            '${widget.topicData['title']} has applications in various fields including all the options mentioned.'
      },
      {
        'question':
            'Which formula is most closely associated with ${widget.topicData['title']}?',
        'options': ['E = mc²', 'F = ma', 'a² + b² = c²', 'PV = nRT'],
        'correctAnswer': 1,
        'explanation':
            'F = ma (Force equals mass times acceleration) is a fundamental formula in ${widget.topicData['title']}.'
      },
    ];

    // Initialize selected answers list
    _selectedAnswers = List.filled(_questions.length, null);
  }

  bool get _allQuestionsAnswered {
    return !_selectedAnswers.any((answer) => answer == null);
  }

  void _submitQuiz() {
    if (!_allQuestionsAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please answer all questions before submitting')),
      );
      return;
    }

    setState(() {
      _hasSubmitted = true;
      _showReview = false;
      _score = 0;

      for (int i = 0; i < _questions.length; i++) {
        if (_selectedAnswers[i] == _questions[i]['correctAnswer']) {
          _score++;
        }
      }
    });
  }

  void _checkAnswers() {
    setState(() {
      _showReview = true;
    });
  }

  void _downloadReport() async {
    // In a real app, this would generate and download a PDF report
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading report...')),
    );

    // Simulate download delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report downloaded successfully!')),
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.topicData['title']} MCQs',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.subjectData['color'],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(widget.subjectData['color']),
            minHeight: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_hasSubmitted)
                  Text(
                    'Score: $_score/${_questions.length}',
                    style: TextStyle(
                      color: widget.subjectData['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),

          // Question content or review
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child:
                  _showReview ? _buildReviewScreen() : _buildCurrentQuestion(),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: _hasSubmitted &&
                    _currentQuestionIndex == _questions.length - 1
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Quiz Submitted!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.subjectData['color'],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Score: $_score/${_questions.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_showReview)
                          ElevatedButton(
                            onPressed: _checkAnswers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.subjectData['color'],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Review Answers'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _downloadReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('Download Report'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to Topics'),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentQuestionIndex > 0
                            ? _previousQuestion
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Previous'),
                      ),
                      if (_allQuestionsAnswered && !_hasSubmitted)
                        ElevatedButton(
                          onPressed: _submitQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.subjectData['color'],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Submit Quiz'),
                        )
                      else
                        const SizedBox(), // Remove Check Answer button
                      ElevatedButton(
                        onPressed: _currentQuestionIndex < _questions.length - 1
                            ? _nextQuestion
                            : _allQuestionsAnswered && !_hasSubmitted
                                ? _submitQuiz
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.subjectData['color'],
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? (_allQuestionsAnswered ? 'Submit' : 'Finish')
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: widget.subjectData['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.subjectData['color']),
          ),
          child: Column(
            children: [
              Text(
                'Quiz Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.subjectData['color'],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $_score/${_questions.length} (${(_score / _questions.length * 100).toStringAsFixed(0)}%)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...List.generate(_questions.length, (index) {
          final question = _questions[index];
          final isCorrect =
              _selectedAnswers[index] == question['correctAnswer'];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Question ${index + 1}${isCorrect ? ' (Correct)' : ' (Incorrect)'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildQuestionReview(question, index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionReview(
      Map<String, dynamic> question, int questionIndex) {
    final List<String> options = question['options'];
    final int correctAnswer = question['correctAnswer'];
    final int? selectedAnswer = _selectedAnswers[questionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isCorrect = index == correctAnswer;
          final isSelected = selectedAnswer == index;

          Color bgColor = Colors.grey.shade100;
          Color borderColor = Colors.grey.shade300;
          IconData? icon;
          Color? iconColor;

          if (isCorrect) {
            bgColor = Colors.green.shade50;
            borderColor = Colors.green;
            icon = Icons.check_circle;
            iconColor = Colors.green;
          } else if (isSelected) {
            bgColor = Colors.red.shade50;
            borderColor = Colors.red;
            icon = Icons.cancel;
            iconColor = Colors.red;
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected || isCorrect ? Colors.black87 : null,
                      fontWeight:
                          isSelected || isCorrect ? FontWeight.bold : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        if (question['explanation'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explanation:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(question['explanation']),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentQuestion() {
    final question = _questions[_currentQuestionIndex];
    final List<String> options = question['options'];
    final int correctAnswer = question['correctAnswer'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(options.length, (index) {
          final isSelected = _selectedAnswers[_currentQuestionIndex] == index;
          final isCorrect = index == correctAnswer;

          Color? backgroundColor;
          Color? borderColor;

          if (_hasSubmitted) {
            if (isSelected && isCorrect) {
              backgroundColor = Colors.green.withValues(alpha: 0.1);
              borderColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              backgroundColor = Colors.red.withValues(alpha: 0.1);
              borderColor = Colors.red;
            } else if (isCorrect) {
              backgroundColor = Colors.green.withValues(alpha: 0.1);
              borderColor = Colors.green;
            } else {
              backgroundColor = Colors.grey.withValues(alpha: 0.1);
              borderColor = Colors.grey;
            }
          } else {
            backgroundColor = isSelected
                ? widget.subjectData['color'].withOpacity(0.1)
                : Colors.grey.withValues(alpha: 0.1);
            borderColor =
                isSelected ? widget.subjectData['color'] : Colors.grey;
          }

          return GestureDetector(
            onTap: _hasSubmitted
                ? null
                : () {
                    setState(() {
                      _selectedAnswers[_currentQuestionIndex] = index;
                    });
                  },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? borderColor : Colors.transparent,
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_hasSubmitted) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explanation:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question['explanation'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
