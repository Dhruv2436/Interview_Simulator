import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/candidate_model.dart';
import 'instructions_screen.dart';

class InterviewSetupScreen extends StatefulWidget {
  final String role;
  final ResumeData? resumeData;
  const InterviewSetupScreen({super.key, required this.role, this.resumeData});

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  int _mcqQuestions = 20;
  int _interviewQuestions = 10;
  final String _timeLimit = '2 Min/Q';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text(
                  'Let\'s set up your interview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  'MCQ Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOptionOption(
                        10,
                        '10 Questions',
                        _mcqQuestions,
                        (v) => setState(() => _mcqQuestions = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOptionOption(
                        20,
                        '20 Questions',
                        _mcqQuestions,
                        (v) => setState(() => _mcqQuestions = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOptionOption(
                        30,
                        '30 Questions',
                        _mcqQuestions,
                        (v) => setState(() => _mcqQuestions = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOptionOption(
                        50,
                        '50 Questions',
                        _mcqQuestions,
                        (v) => setState(() => _mcqQuestions = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: const Text(
                  'Interview Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOptionOption(
                        5,
                        '5 Questions',
                        _interviewQuestions,
                        (v) => setState(() => _interviewQuestions = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOptionOption(
                        10,
                        '10 Questions',
                        _interviewQuestions,
                        (v) => setState(() => _interviewQuestions = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOptionOption(
                        15,
                        '15 Questions',
                        _interviewQuestions,
                        (v) => setState(() => _interviewQuestions = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: const Text(
                  'Time Per Question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeInUp(
                delay: const Duration(milliseconds: 420),
                child: const Text(
                  'Total time = 2 × Number of MCQs',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  'Passing Criteria',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 550),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Resume ATS Score: ≥ 50% to proceed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• MCQ Passing Marks: ≥ 75% for Interview',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Each section must be fully completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InstructionsScreen(
                            role: widget.role,
                            mcqQuestions: _mcqQuestions,
                            interviewQuestions: _interviewQuestions,
                            resumeData: widget.resumeData,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B42FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionOption<T>(
    T value,
    String label,
    T groupValue,
    ValueChanged<T> onChanged,
  ) {
    return _buildOptionBlock(
      value == groupValue,
      label,
      () => onChanged(value),
    );
  }

  Widget _buildOptionOptionStr<T>(
    T value,
    String label,
    T groupValue,
    ValueChanged<T> onChanged,
  ) {
    return _buildOptionBlock(
      value == groupValue,
      label,
      () => onChanged(value),
      true,
    );
  }

  Widget _buildOptionBlock(
    bool isSelected,
    String label,
    VoidCallback onTap, [
    bool isWrap = false,
  ]) {
    final block = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5B42FA).withOpacity(0.08)
              : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF5B42FA) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: isWrap ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? const Color(0xFF5B42FA)
                  : Colors.grey.shade400,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF5B42FA) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return block;
  }
}
