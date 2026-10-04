import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'ai_interview_screen.dart';

class MCQResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final Map<String, dynamic>? candidateProfile;
  final String? technicalDomain;
  // Full question list + user's selections for review
  final List<Map<String, dynamic>> questions;
  final Map<int, int?> selectedOptions;

  const MCQResultScreen({
    super.key,
    this.score = 0,
    this.total = 0,
    this.candidateProfile,
    this.technicalDomain,
    this.questions = const [],
    this.selectedOptions = const {},
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (score / total) * 100 : 0;
    final bool passed = percentage >= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              FadeInDown(
                child: Icon(
                  passed
                      ? Icons.emoji_events_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  color: passed ? const Color(0xFFF59E0B) : Colors.redAccent,
                  size: 88,
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  passed ? 'Well Done! 🎉' : 'Keep Practicing!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'You completed the MCQ round.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 36),

              // Score Ring
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Score',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$score',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              ' / $total',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    SizedBox(
                      height: 88,
                      width: 88,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: total > 0 ? score / total : 0,
                            strokeWidth: 9,
                            backgroundColor: Colors.grey.shade200,
                            color: passed
                                ? const Color(0xFF10B981)
                                : Colors.redAccent,
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Text(
                              '${percentage.round()}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: passed
                                    ? const Color(0xFF10B981)
                                    : Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status card
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: passed
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: passed
                          ? const Color(0xFF10B981)
                          : Colors.redAccent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            passed ? Icons.check_circle : Icons.cancel,
                            color: passed
                                ? const Color(0xFF10B981)
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            passed
                                ? 'QUALIFIED FOR INTERVIEW ROUND'
                                : 'NOT QUALIFIED',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: passed
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF991B1B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        passed
                            ? 'Excellent! You scored ${percentage.round()}% which meets the 75% threshold. You may proceed to the AI Interview round.'
                            : 'You scored ${percentage.round()}% which is below the required 75%. Please review the material and try again.',
                        style: TextStyle(
                          color: passed
                              ? const Color(0xFF065F46)
                              : const Color(0xFF7F1D1D),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: passed
                                ? const Color(0xFF065F46)
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Passing threshold: 75%',
                            style: TextStyle(
                              color: passed
                                  ? const Color(0xFF065F46)
                                  : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Review Answers Button — always visible
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showReviewSheet(context),
                    icon: const Icon(
                      Icons.quiz_outlined,
                      color: Color(0xFF5B42FA),
                    ),
                    label: const Text(
                      'Review All Answers',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B42FA),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF5B42FA),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Conditional action button
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: passed
                      ? ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AIInterviewScreen(
                                mcqScore: score,
                                totalMcq: total,
                                candidateProfile: candidateProfile,
                                technicalDomain: technicalDomain,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Continue to AI Interview',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B42FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                          icon: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'Return to Home',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.97,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.quiz_outlined, color: Color(0xFF5B42FA)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Answer Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '$score / $total correct',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Questions list
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.isEmpty ? 1 : questions.length,
                  itemBuilder: (ctx, i) {
                    if (questions.isEmpty) {
                      return const Center(
                        child: Text(
                          'No question data available.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    final q = questions[i];
                    final options = q['options'] as List<dynamic>;
                    final correctIdx = q['correctIndex'] as int? ?? -1;
                    final userIdx = selectedOptions[i];
                    final isCorrect = userIdx != null && userIdx == correctIdx;
                    final notAnswered = userIdx == null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: notAnswered
                              ? Colors.grey.shade300
                              : isCorrect
                              ? const Color(0xFF10B981)
                              : Colors.redAccent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: notAnswered
                                  ? Colors.grey.shade50
                                  : isCorrect
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(13),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Q${i + 1}. ${q['statement']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  notAnswered
                                      ? Icons.radio_button_unchecked
                                      : isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: notAnswered
                                      ? Colors.grey
                                      : isCorrect
                                      ? const Color(0xFF10B981)
                                      : Colors.redAccent,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          // Options
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: List.generate(options.length, (oi) {
                                final letters = ['A', 'B', 'C', 'D', 'E'];
                                final optText = options[oi]
                                    .toString()
                                    .replaceFirst(RegExp(r'^[A-E]\.\s*'), '');
                                final isCorrectOpt = oi == correctIdx;
                                final isUserOpt = oi == userIdx;
                                Color? bg;
                                Color? border;
                                if (isCorrectOpt) {
                                  bg = const Color(0xFFD1FAE5);
                                  border = const Color(0xFF10B981);
                                } else if (isUserOpt && !isCorrect) {
                                  bg = const Color(0xFFFEE2E2);
                                  border = Colors.redAccent;
                                } else {
                                  bg = Colors.grey.shade50;
                                  border = Colors.grey.shade200;
                                }
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    border: Border.all(color: border),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCorrectOpt
                                              ? const Color(0xFF10B981)
                                              : isUserOpt
                                              ? Colors.redAccent
                                              : Colors.grey.shade300,
                                        ),
                                        child: Center(
                                          child: Text(
                                            letters[oi],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isCorrectOpt
                                                ? const Color(0xFF065F46)
                                                : isUserOpt
                                                ? const Color(0xFF7F1D1D)
                                                : Colors.black87,
                                            fontWeight:
                                                isCorrectOpt || isUserOpt
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (isCorrectOpt)
                                        const Text(
                                          '✓ Correct',
                                          style: TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (isUserOpt && !isCorrectOpt)
                                        const Text(
                                          '✗ Your Answer',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Explanation if available
                          if (q['explanation'] != null &&
                              q['explanation'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      color: Color(0xFF3B82F6),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        q['explanation'].toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
