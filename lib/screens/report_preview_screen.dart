import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/pdf_report_service.dart';
import '../services/face_detector_service.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

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
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text(
                  'AI Interview Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeInDown(
                delay: const Duration(milliseconds: 50),
                child: const Text('Generated on 25 July 2026', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
              const SizedBox(height: 24),

              // Profile box
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF5B42FA), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Candidate Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          const Text('Software Engineer', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView(
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: const Text('Report Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildBreakdownRow('ATS Score', '78%'),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      child: _buildBreakdownRow('MCQ Score', '80%'),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildBreakdownRow('Technical Interview', '88%'),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _buildBreakdownRow('Communication', '85%'),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildBreakdownRow('Confidence', '82%'),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B42FA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Overall Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5B42FA))),
                            const Text('84%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5B42FA))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: const Text('Strengths', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 550),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BulletText('Strong knowledge of technical domain'),
                          SizedBox(height: 8),
                          _BulletText('Good problem solving skills'),
                          SizedBox(height: 8),
                          _BulletText('Clear communication'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      await PdfReportGenerator.generateAndSharePdfReport(
                        context: context,
                        candidateName: 'Candidate',
                        targetCompany: 'Tech Corp',
                        targetRole: 'Software Engineer',
                        overallScore: 84.0,
                        faceAnalytics: RealFaceAnalytics(
                          isFaceDetected: true,
                          positionStatus: 'Centered',
                          eyeContactStatus: 'Good',
                          headAngleY: 0.0,
                          headAngleZ: 0.0,
                          headAngleX: 0.0,
                          confidenceScore: 0.88,
                          eyeContactScore: 0.92,
                          facialEngagementScore: 0.90,
                          eyeContactPercentage: 88.5,
                          attentionScore: 92.0,
                          faceCount: 1,
                          headPoseStatus: 'Centered',
                          presenceStatus: 'Present throughout',
                          estimatedEmotion: 'Confident',
                        ),
                        evaluations: [
                          {
                            'question': 'Tell me about yourself and your technical experience.',
                            'answer': 'I am a passionate software developer with strong problem-solving skills.',
                            'score': 9,
                            'strengths': 'Clear structure and confident speech.',
                            'improvements': 'Add more metrics on past projects.',
                          },
                        ],
                        candidateProfile: {
                          'name': 'Candidate',
                          'education': 'B.Tech Computer Science',
                          'experience': 'Fresher',
                          'skills': ['Flutter', 'Dart', 'REST API'],
                        },
                        report: {
                          'mcqScorePercent': 80,
                          'voiceScorePercent': 88,
                          'communicationRating': 8.5,
                          'technicalDepthRating': 8.8,
                          'confidenceRating': 8.2,
                          'hiringRecommendation': 'Strong Hire',
                          'summary': 'Demonstrated outstanding technical domain knowledge and clear communication.',
                          'keyStrengths': [
                            'Strong technical knowledge',
                            'Good problem solving skills',
                            'Clear communication',
                          ],
                          'areasForImprovement': [
                            'Elaborate on edge-case error handling',
                          ],
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B42FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Download PDF Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String title, String score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(score, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
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
          child: CircleAvatar(radius: 2, backgroundColor: Colors.black87),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
