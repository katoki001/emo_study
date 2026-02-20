import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

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
  late List<dynamic> questions;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> userAnswers = [];
  bool isAssessmentComplete = false;
  bool isLoading = false;
  String? aiFeedback;

  @override
  void initState() {
    super.initState();
    // Initialize questions from the passed data
    questions = List.from(widget.assessmentData['questions']);
  }

  Future<void> _submitAnswer(String selectedOption) async {
    setState(() => isLoading = true);

    final currentQuestion = questions[currentQuestionIndex];
    final String correctAnswer = currentQuestion['correctAnswer'];
    final bool isCorrect = selectedOption == correctAnswer;

    // 1. Record Answer
    userAnswers.add({
      'question': currentQuestion['question'],
      'selected': selectedOption,
      'correct': correctAnswer,
      'isCorrect': isCorrect,
    });

    try {
      // 2. Get AI Feedback (Encouragement/Correction)
      final feedbackPrompt =
          "The student is studying ${widget.subject}. Question: '${currentQuestion['question']}'. User answered '$selectedOption'. Correct answer is '$correctAnswer'. Give a 10-word max encouraging correction.";
      final feedback = await AIService.getAIResponse(feedbackPrompt);

      // 3. Check if we should end or continue (Limit to 5 questions)
      if (currentQuestionIndex >= 4) {
        setState(() {
          aiFeedback = feedback;
          isAssessmentComplete = true;
          isLoading = false;
        });
      } else {
        // 4. Generate Adaptive Next Question
        final nextPrompt =
            '''Generate a multiple choice question about ${widget.subject}. 
        The student got the last one ${isCorrect ? "right" : "wrong"}. 
        Return ONLY valid JSON in this format: 
        {"question": "string", "options": ["a", "b", "c", "d"], "correctAnswer": "string"}''';

        final aiResponse = await AIService.getAIResponse(nextPrompt);

        // 5. Clean and Parse the JSON
        final cleanJson = AIService.cleanJson(aiResponse);
        final Map<String, dynamic> nextQuestion = jsonDecode(cleanJson);

        setState(() {
          questions.add(nextQuestion);
          aiFeedback = feedback;
          currentQuestionIndex++;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Quiz logic error: $e");
      // Fallback: If AI fails to generate a new question, end the quiz gracefully
      setState(() {
        isLoading = false;
        isAssessmentComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.subject} Assessment'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isAssessmentComplete ? _buildResults() : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = questions[currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Indicator
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / 5,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 20),

        // AI Feedback Section
        if (aiFeedback != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Text(
              "Tutor: $aiFeedback",
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Question Text
        Text(
          "Question ${currentQuestionIndex + 1}:",
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          q['question'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        // Options List
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.builder(
              itemCount: (q['options'] as List).length,
              itemBuilder: (context, i) {
                final option = q['options'][i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.deepPurple[100]!),
                      ),
                    ),
                    onPressed: () => _submitAnswer(option),
                    child: Text(option, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResults() {
    int score = userAnswers.where((a) => a['isCorrect'] == true).length;
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text("Assessment Complete!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("You scored $score out of ${userAnswers.length}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Return to Home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
