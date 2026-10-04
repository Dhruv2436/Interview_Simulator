import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'mcq_result_screen.dart';
import '../services/openai_service.dart';

class MCQTestScreen extends StatefulWidget {
  final Map<String, dynamic>? candidateProfile;
  final String technicalDomain;
  final int numAptitude;
  final int numTechnical;
  final int minutesPerQuestion; // NEW: set by interviewer (1, 2, or 3 min/Q)

  const MCQTestScreen({
    super.key,
    this.candidateProfile,
    required this.technicalDomain,
    required this.numAptitude,
    required this.numTechnical,
    this.minutesPerQuestion = 2, // default 2 minutes per question
  });

  @override
  State<MCQTestScreen> createState() => _MCQTestScreenState();
}

class _MCQTestScreenState extends State<MCQTestScreen> {
  int _currentQuestionIndex = 0;
  // Map: questionIndex -> selectedOptionIndex
  final Map<int, int?> _selectedOptions = {};
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _timeUp = false;

  // Timer fields
  int _totalSeconds = 0;
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final qs = await OpenAIService().generateMCQs(
      candidateProfile: widget.candidateProfile ?? {},
      technicalDomain: widget.technicalDomain,
      numAptitude: widget.numAptitude,
      numTechnical: widget.numTechnical,
    );
    final total = widget.numAptitude + widget.numTechnical;
    // Dynamic timer: minutesPerQuestion * 60 seconds per question
    _totalSeconds = total * widget.minutesPerQuestion * 60;
    _remainingSeconds = _totalSeconds;
    setState(() {
      _questions = qs;
      _isLoading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        t.cancel();
        setState(() => _timeUp = true);
        _finishTest();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    final pct = _remainingSeconds / _totalSeconds;
    if (pct > 0.5) return const Color(0xFF10B981);
    if (pct > 0.25) return const Color(0xFFF59E0B);
    return Colors.redAccent;
  }

  int get _calculatedScore {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      final selected = _selectedOptions[i];
      if (selected != null && selected == _questions[i]['correctIndex']) {
        score++;
      }
    }
    return score;
  }

  void _goNext() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _finishTest();
    }
  }

  void _goPrevious() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _finishTest() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MCQResultScreen(
          score: _calculatedScore,
          total: _questions.length,
          candidateProfile: widget.candidateProfile,
          technicalDomain: widget.technicalDomain,
          questions: _questions,
          selectedOptions: _selectedOptions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _timerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _timerColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, color: _timerColor, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      color: _timerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        leadingWidth: 110,
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'Q ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF5B42FA)),
                    SizedBox(height: 16),
                    Text('Generating questions with AI...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : _questions.isEmpty
                ? const Center(child: Text('Failed to load questions.'))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: _buildQuestionBody(),
                  ),
      ),
    );
  }

  Widget _buildQuestionBody() {
    final curQ = _questions[_currentQuestionIndex];
    final options = curQ['options'] as List<dynamic>;
    final selectedOpt = _selectedOptions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF5B42FA),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 16),

        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF5B42FA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${curQ['category']} — ${curQ['topic'] ?? widget.technicalDomain}',
            style: const TextStyle(
              color: Color(0xFF5B42FA),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Question
        FadeIn(
          key: ValueKey(_currentQuestionIndex),
          child: Text(
            curQ['statement'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Options
        ...List.generate(options.length, (index) {
          final letters = ['A', 'B', 'C', 'D', 'E'];
          final optStr = options[index].toString();
          final cleanOpt = optStr.replaceFirst(RegExp(r'^[A-E]\.\s*'), '');
          return _buildOption(index, letters[index], cleanOpt, selectedOpt);
        }),

        const SizedBox(height: 24),

        // Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _currentQuestionIndex > 0 ? _goPrevious : null,
              icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
              label: const Text('Previous', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B42FA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Submit Test',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _currentQuestionIndex < _questions.length - 1 ? Icons.arrow_forward_ios : Icons.check_circle_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Question pagination dots
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_questions.length, (i) {
              final answered = _selectedOptions.containsKey(i) && _selectedOptions[i] != null;
              final isActive = i == _currentQuestionIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentQuestionIndex = i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF5B42FA)
                        : answered
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : Colors.white,
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF5B42FA)
                          : answered
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : answered ? const Color(0xFF10B981) : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOption(int index, String letter, String text, int? selectedOpt) {
    final isSelected = index == selectedOpt;
    return GestureDetector(
      onTap: () => setState(() => _selectedOptions[_currentQuestionIndex] = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B42FA).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF5B42FA) : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF5B42FA) : Colors.grey.shade100,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF5B42FA) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF5B42FA), size: 20),
          ],
        ),
      ),
    );
  }
}
