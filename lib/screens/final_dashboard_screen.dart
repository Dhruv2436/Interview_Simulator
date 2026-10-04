import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'report_preview_screen.dart';
import '../services/pdf_report_service.dart';
import '../services/face_detector_service.dart';

class FinalDashboardScreen extends StatefulWidget {
  final int mcqScore;
  final int totalMcq;
  final int atsScore;
  final int interviewScore;
  final int skillsCount;
  final Map<String, dynamic>? candidateProfile;
  final String? technicalDomain;
  final List<Map<String, dynamic>>? evaluations;
  final RealFaceAnalytics? faceAnalytics;

  const FinalDashboardScreen({
    super.key,
    this.mcqScore = 0,
    this.totalMcq = 0,
    this.atsScore = 0,
    this.interviewScore = 0,
    this.skillsCount = 0,
    this.candidateProfile,
    this.technicalDomain,
    this.evaluations,
    this.faceAnalytics,
  });

  @override
  State<FinalDashboardScreen> createState() => _FinalDashboardScreenState();
}

class _FinalDashboardScreenState extends State<FinalDashboardScreen> {
  int _overallScore = 0;
  int _mcqPercent = 0;
  int _atsPercent = 0;
  int _techPercent = 0;
  int _skillsCount = 0;

  @override
  void initState() {
    super.initState();
    _calculateScores();
  }

  void _calculateScores() {
    _mcqPercent = widget.totalMcq > 0
        ? ((widget.mcqScore / widget.totalMcq) * 100).round().clamp(0, 100)
        : 0;

    _atsPercent = (widget.candidateProfile?['score'] as int?) ?? widget.atsScore;

    if (widget.evaluations != null && widget.evaluations!.isNotEmpty) {
      double totalScore = 0;
      for (var ev in widget.evaluations!) {
        totalScore += (ev['score'] as num? ?? 0).toDouble();
      }
      _techPercent = ((totalScore / widget.evaluations!.length) * 10).round().clamp(0, 100);
    } else {
      _techPercent = widget.interviewScore.clamp(0, 100);
    }

    final skillsList = widget.candidateProfile?['skills'];
    if (skillsList is List && skillsList.isNotEmpty) {
      _skillsCount = skillsList.length;
    } else {
      _skillsCount = widget.skillsCount;
    }

    // Weighted Overall Score (35% ATS, 30% MCQ, 35% Interview)
    _overallScore = ((_atsPercent * 0.35) + (_mcqPercent * 0.30) + (_techPercent * 0.35)).round().clamp(0, 100);
  }

  String _getHiringRecommendation(int score) {
    if (score >= 75) {
      return 'Strong Hire';
    } else if (score >= 50) {
      return 'Hire';
    } else {
      return 'Do Not Hire';
    }
  }

  Future<void> _downloadPdfReport() async {
    final profile = widget.candidateProfile ?? {
      'name': 'Candidate',
      'skills': ['Flutter', 'Dart', 'REST API', 'Git', 'SQL'],
      'education': 'B.Tech Computer Science',
      'experience': 'Fresher',
    };

    final analytics = widget.faceAnalytics ?? RealFaceAnalytics.empty();

    final evals = widget.evaluations ?? [
      {
        'question': 'Tell me about yourself and your technical background.',
        'answer': 'I have a solid foundation in computer science and mobile app development using Flutter.',
        'score': 8,
        'strengths': 'Clear structure and communication.',
        'improvements': 'Provide deeper metrics on past projects.',
      },
    ];

    final String recommendation = _getHiringRecommendation(_overallScore);

    final reportMap = {
      'mcqScorePercent': _mcqPercent,
      'voiceScorePercent': _techPercent,
      'communicationRating': (_techPercent / 10.0),
      'technicalDepthRating': (_techPercent / 10.0),
      'confidenceRating': (_techPercent / 10.0),
      'hiringRecommendation': recommendation,
      'summary': recommendation == 'Do Not Hire'
          ? 'Candidate achieved an overall score of $_overallScore%, which is below the minimum threshold (50%). Further preparation is recommended.'
          : 'Candidate demonstrated proficiency with an overall score of $_overallScore%. Recommended for hiring consideration.',
      'keyStrengths': [
        'MCQ Technical knowledge: $_mcqPercent%',
        'ATS Profile relevance: $_atsPercent%',
        'Interview technical performance: $_techPercent%',
      ],
      'areasForImprovement': [
        'Focus on edge-case scenario handling',
        'Enhance domain-specific architectural depth',
      ],
    };

    await PdfReportGenerator.generateAndSharePdfReport(
      context: context,
      candidateName: profile['name'] as String? ?? 'Candidate',
      targetCompany: 'Tech Corp',
      targetRole: widget.technicalDomain ?? 'Software Engineer',
      overallScore: _overallScore.toDouble(),
      faceAnalytics: analytics,
      evaluations: evals,
      candidateProfile: profile,
      report: reportMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header Icon & Title ──
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Interview Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Here is your overall performance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Overall Score Circular Gauge Card ──
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFEEF2FF), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CustomPaint(
                          painter: GradientCircularProgressPainter(
                            progress: _overallScore / 100.0,
                            strokeWidth: 15.0,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_overallScore%',
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F766E),
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Overall Score',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── 2x2 Grid Score Cards ──
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.person_outline_rounded,
                            iconBg: const Color(0xFFE0F2FE),
                            iconColor: const Color(0xFF0284C7),
                            label: 'ATS Score',
                            value: '$_atsPercent%',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.assignment_outlined,
                            iconBg: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF4F46E5),
                            label: 'MCQ Score',
                            value: '$_mcqPercent%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.mic_none_rounded,
                            iconBg: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF4F46E5),
                            label: 'Interview Score',
                            value: '$_techPercent%',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.settings_outlined,
                            iconBg: const Color(0xFFE0F2FE),
                            iconColor: const Color(0xFF0284C7),
                            label: 'Skills Assessed',
                            value: '$_skillsCount',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Action Buttons ──
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportPreviewScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_outlined, color: Colors.white, size: 20),
                    label: const Text(
                      'View Detailed Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 450),
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _downloadPdfReport,
                    icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 22),
                    label: const Text(
                      'Download PDF Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F766E),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Circular Progress Ring Painter with Multi-Stop Gradient
class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  GradientCircularProgressPainter({
    required this.progress,
    this.strokeWidth = 15.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Foreground dual/multi gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = const SweepGradient(
      startAngle: -1.5707963, // Top position (-90 deg)
      endAngle: 4.71238898,
      colors: [
        Color(0xFFA3E635), // Lime Green
        Color(0xFF10B981), // Emerald
        Color(0xFF06B6D4), // Cyan
        Color(0xFF0284C7), // Teal Blue
        Color(0xFFA3E635),
      ],
      stops: [0.0, 0.25, 0.65, 0.85, 1.0],
    );

    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -1.5707963;
    final sweepAngle = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);

    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
  }
}
