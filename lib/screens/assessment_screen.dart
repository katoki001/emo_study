import 'dart:convert';
import 'dart:math';

import 'package:ai_learning_companion/services/assessment_api.dart';
import 'package:flutter/material.dart';

class AssessmentScreen extends StatefulWidget {
  final String subject;
  final Map<String, dynamic> assessmentData;

  const AssessmentScreen({
    super.key,
    required this.subject,
    required this.assessmentData,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> userAnswers = [];
  bool isAssessmentComplete = false;
  bool isLoading = false;
  String? aiFeedback;

  get subject => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Assessment'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {},
          ),
          // Add health indicator
          FutureBuilder<bool>(
            future: AIService.checkHealth(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: snapshot.data == true ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isAssessmentComplete
            ? _buildResultsScreen()
            : _buildQuestionScreen(),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final questions = widget.assessmentData['questions'] ?? [];

    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return const Center(
        child: Text('No questions available'),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / questions.length,
        ),
        const SizedBox(height: 16),

        // Question number
        Text(
          'Question ${currentQuestionIndex + 1} of ${questions.length}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // Question text
        Text(
          currentQuestion['question'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Show AI feedback if available
        if (aiFeedback != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Feedback:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(aiFeedback!),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Loading indicator
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          // Options
          Expanded(
            child: ListView.builder(
              itemCount: currentQuestion['options'].length,
              itemBuilder: (context, index) {
                final option = currentQuestion['options'][index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(option),
                    onTap: () => _submitAnswer(option),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Assessment Complete!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Subject: ${widget.subject}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Questions Answered: ${userAnswers.length}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Get AI summary of performance
          FutureBuilder<String>(
            future: _getAssessmentSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'AI Assessment Summary:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(snapshot.data!),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Return to Subjects'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer(String answer) async {
    setState(() {
      isLoading = true;
      aiFeedback = null;
    });

    // Save answer locally
    userAnswers.add({
      'question_index': currentQuestionIndex,
      'answer': answer,
      'correct_answer': widget.assessmentData['questions'][currentQuestionIndex]
          ['correctAnswer'],
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      // 1. Get AI feedback on the answer
      final feedbackPrompt = '''
Subject: ${widget.subject}
Question: ${widget.assessmentData['questions'][currentQuestionIndex]['question']}
Student's Answer: $answer
Correct Answer: ${widget.assessmentData['questions'][currentQuestionIndex]['correctAnswer']}

Provide brief, encouraging feedback on this answer. Keep it under 2 sentences.
''';

      final feedback = await AIService.getAIResponse(feedbackPrompt);

      // 2. Generate next question or adapt difficulty
      final isCorrect = answer ==
          widget.assessmentData['questions'][currentQuestionIndex]
              ['correctAnswer'];

      // Check if assessment is complete
      if (currentQuestionIndex + 1 >=
          widget.assessmentData['questions'].length) {
        setState(() {
          isAssessmentComplete = true;
          isLoading = false;
        });

        // Save all results
        _saveAssessmentResults();
      } else {
        // Get adaptive next question from AI based on performance
        final nextQuestionPrompt = '''
Generate a follow-up question for a student studying $subject.
Previous question: ${widget.assessmentData['questions'][currentQuestionIndex]['question']}
Student ${isCorrect ? 'answered correctly' : 'struggled with this'}.
Difficulty: ${isCorrect ? 'slightly harder' : 'similar difficulty'}
Topic: ${widget.subject}

Generate a JSON response with format: {"question": "...", "options": ["...", "...", "...", "..."], "correctAnswer": "..."}
Make it educational and appropriate.
''';

        final nextQuestionJson =
            await AIService.getAIResponse(nextQuestionPrompt);

        try {
          // Parse AI-generated question
          final Map<String, dynamic> newQuestion = jsonDecode(nextQuestionJson);

          setState(() {
            currentQuestionIndex++;
            aiFeedback = feedback;
            // Add AI-generated question to the list
            widget.assessmentData['questions'].add(newQuestion);
            isLoading = false;
          });
        } catch (e) {
          // If JSON parsing fails, just move to next pre-defined question
          setState(() {
            currentQuestionIndex++;
            aiFeedback = feedback;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        aiFeedback = "AI feedback unavailable. Moving to next question.";
      });

      // Still move to next question even if AI fails
      if (currentQuestionIndex + 1 <
          widget.assessmentData['questions'].length) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            currentQuestionIndex++;
          });
        });
      } else {
        setState(() {
          isAssessmentComplete = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'AI service: ${e.toString().substring(0, min(50, e.toString().length))}...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<String> _getAssessmentSummary() async {
    try {
      // Create a summary of the assessment
      final correctAnswers =
          userAnswers.where((a) => a['answer'] == a['correct_answer']).length;

      final summaryPrompt = '''
Assessment completed for subject: ${widget.subject}
Total questions: ${userAnswers.length}
Correct answers: $correctAnswers
Topics covered: ${widget.subject}

Provide a brief, encouraging 2-sentence summary of the student's performance.
''';

      return await AIService.getAIResponse(summaryPrompt);
    } catch (e) {
      return "Great job completing the assessment! Keep practicing to improve further.";
    }
  }

  void _saveAssessmentResults() {
    // Calculate score
    final correctCount =
        userAnswers.where((a) => a['answer'] == a['correct_answer']).length;

    final score = (correctCount / userAnswers.length * 100).round();

    final results = {
      'subject': widget.subject,
      'date': DateTime.now().toIso8601String(),
      'score': score,
      'total_questions': userAnswers.length,
      'correct_answers': correctCount,
      'answers': userAnswers,
    };

    // Save to local storage
    print('Assessment results: $results');

    // TODO: Save to SharedPreferences or local database
  }
}
