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
    if (!_allQuestionsAnswered) return;

    setState(() {
      _hasSubmitted = true;
      _score = 0;

      for (int i = 0; i < _questions.length; i++) {
        if (_selectedAnswers[i] == _questions[i]['correctAnswer']) {
          _score++;
        }
      }
    });
  }

  void _checkAnswers() {
    // This will now only show the current question's answer
    setState(() {
      _hasSubmitted = true;
    });
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

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentQuestion(),
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
                      children: [
                        Text(
                          'Your Score: $_score/${_questions.length}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.subjectData['color'],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate back or show review options
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.subjectData['color'],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Finish'),
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
                        ElevatedButton(
                          onPressed: _hasSubmitted ? null : _checkAnswers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.subjectData['color'],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Check Answer'),
                        ),
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
                              ? 'Submit'
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
