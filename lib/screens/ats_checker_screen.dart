import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'extracted_info_screen.dart';
import '../models/candidate_model.dart';

class ATSCheckerScreen extends StatelessWidget {
  final String role;
  final ATSAnalysisResult analysis;
  final ResumeData resumeData;
  final String jobDescription;

  const ATSCheckerScreen({
    super.key,
    required this.role,
    required this.analysis,
    required this.resumeData,
    this.jobDescription = '',
  });

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF10B981); // green
    if (score >= 50) return const Color(0xFFF59E0B); // amber
    return const Color(0xFFEF4444); // red
  }

  @override
  Widget build(BuildContext context) {
    final bool hasJD = jobDescription.isNotEmpty;
    final bool hasLLMScores =
        analysis.educationScore > 0 || analysis.skillsScore > 0 || analysis.experienceScore > 0;

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Badge
              FadeInDown(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ATS Analysis Report',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (hasJD)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B42FA).withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF5B42FA).withAlpha(80)),
                        ),
                        child: const Text(
                          'AI Scored',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B42FA),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Final Score Donut
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        width: 130,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: analysis.score / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: _scoreColor(analysis.score),
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${analysis.score}%',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: _scoreColor(analysis.score),
                                    ),
                                  ),
                                  const Text(
                                    'ATS Score',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${analysis.strengthSummary} 🌟',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor(analysis.score),
                        ),
                      ),
                      if (analysis.overallExplanation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            analysis.overallExplanation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Section Score Breakdown (Education / Skills / Experience) ──
              if (hasLLMScores) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: const Text(
                    'Section Score Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                FadeInUp(
                  delay: const Duration(milliseconds: 160),
                  child: const Text(
                    'Education 25%  •  Skills 40%  •  Experience 35%',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  child: _SectionScoreCard(
                    icon: Icons.school_outlined,
                    label: 'Education',
                    score: analysis.educationScore,
                    weight: '25%',
                    reasoning: analysis.educationReasoning,
                    suggestion: analysis.educationSuggestions,
                    color: _scoreColor(analysis.educationScore),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _SectionScoreCard(
                    icon: Icons.code_outlined,
                    label: 'Skills',
                    score: analysis.skillsScore,
                    weight: '40%',
                    reasoning: analysis.skillsReasoning,
                    suggestion: analysis.skillsSuggestions,
                    color: _scoreColor(analysis.skillsScore),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 220),
                  child: _SectionScoreCard(
                    icon: Icons.work_outline,
                    label: 'Experience',
                    score: analysis.experienceScore,
                    weight: '35%',
                    reasoning: analysis.experienceReasoning,
                    suggestion: analysis.experienceSuggestions,
                    color: _scoreColor(analysis.experienceScore),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Fallback breakdown (keyword-based)
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: const Text(
                    'ATS Score Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildBreakdownRow(
                    'Skills Match',
                    analysis.skillsScore > 0 ? analysis.skillsScore : (resumeData.skills.isNotEmpty ? 65 : 0),
                    resumeData.skills.isNotEmpty ? Colors.green : Colors.red,
                    resumeData.skills.isNotEmpty ? Icons.check_circle : Icons.cancel,
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 225),
                  child: _buildBreakdownRow(
                    'Education',
                    resumeData.college.isNotEmpty ? 80 : 0,
                    resumeData.college.isNotEmpty ? Colors.green : Colors.red,
                    resumeData.college.isNotEmpty ? Icons.check_circle : Icons.cancel,
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: _buildBreakdownRow(
                    'Experience',
                    (resumeData.experience.isNotEmpty && resumeData.experience.first.trim().isNotEmpty) ? 65 : 0,
                    (resumeData.experience.isNotEmpty && resumeData.experience.first.trim().isNotEmpty) ? Colors.orange : Colors.red,
                    (resumeData.experience.isNotEmpty && resumeData.experience.first.trim().isNotEmpty) ? Icons.warning_rounded : Icons.cancel,
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 275),
                  child: _buildBreakdownRow(
                    'Projects',
                    resumeData.projects.isNotEmpty ? 75 : 0,
                    resumeData.projects.isNotEmpty ? Colors.orange : Colors.red,
                    resumeData.projects.isNotEmpty ? Icons.warning_rounded : Icons.cancel,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Matched / Missing Skills ──
              if (analysis.matchedSkills.isNotEmpty || analysis.missingSkills.isNotEmpty) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 280),
                  child: const Text(
                    'Skill Analysis',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                if (analysis.matchedSkills.isNotEmpty) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 290),
                    child: _SkillChipsRow(
                      label: '✅ Matched Skills',
                      skills: analysis.matchedSkills,
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFD1FAE5),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (analysis.missingSkills.isNotEmpty)
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _SkillChipsRow(
                      label: '❌ Missing Skills',
                      skills: analysis.missingSkills,
                      color: const Color(0xFFEF4444),
                      bgColor: const Color(0xFFFEE2E2),
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // ── Suggestions ──
              FadeInUp(
                delay: const Duration(milliseconds: 320),
                child: const Text(
                  'Suggestions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delay: const Duration(milliseconds: 340),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: analysis.suggestions
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _BulletText(s),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  children: [
                    // Gate status banner
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: analysis.score >= 50 ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: analysis.score >= 50 ? const Color(0xFF10B981) : Colors.redAccent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            analysis.score >= 50 ? Icons.check_circle : Icons.cancel,
                            color: analysis.score >= 50 ? const Color(0xFF10B981) : Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              analysis.score >= 50
                                  ? 'Resume matches requirement (${analysis.score}% ≥ 50%). You may proceed!'
                                  : 'ATS score too low (${analysis.score}% < 50%). Please improve your resume.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: analysis.score >= 50 ? const Color(0xFF065F46) : const Color(0xFF7F1D1D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: analysis.score >= 50
                          ? ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExtractedInfoScreen(
                                      role: role,
                                      resumeData: resumeData,
                                      analysis: analysis,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                              label: const Text(
                                'Continue to Interview',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B42FA),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                              icon: const Icon(Icons.home, color: Colors.white, size: 20),
                              label: const Text(
                                'Return to Home',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String title, int score, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text('$score%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ── Section score card with progress bar + collapsible reasoning ──
class _SectionScoreCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final int score;
  final String weight;
  final String reasoning;
  final String suggestion;
  final Color color;

  const _SectionScoreCard({
    required this.icon,
    required this.label,
    required this.score,
    required this.weight,
    required this.reasoning,
    required this.suggestion,
    required this.color,
  });

  @override
  State<_SectionScoreCard> createState() => _SectionScoreCardState();
}

class _SectionScoreCardState extends State<_SectionScoreCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      widget.weight,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.score}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: widget.score / 100,
                    backgroundColor: Colors.grey.shade100,
                    color: widget.color,
                    minHeight: 8,
                  ),
                ),
                if (widget.reasoning.isNotEmpty || widget.suggestion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      children: [
                        Text(
                          _expanded ? 'Hide details' : 'View reasoning & tips',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: widget.color,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.reasoning.isNotEmpty) ...[
                    const Text(
                      'Reasoning',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.reasoning,
                      style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
                    ),
                  ],
                  if (widget.suggestion.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Suggestion',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.suggestion,
                      style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Skill chip pills row ──
class _SkillChipsRow extends StatelessWidget {
  final String label;
  final List<String> skills;
  final Color color;
  final Color bgColor;

  const _SkillChipsRow({
    required this.label,
    required this.skills,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: skills
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
          child: CircleAvatar(radius: 2.5, backgroundColor: Color(0xFF5B42FA)),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.6),
          ),
        ),
      ],
    );
  }
}
