import 'package:flutter/material.dart';
import 'permission_gate_screen.dart';
import 'interview_screen.dart';

/// Bridge screen: routes from MCQ result → Permission Gate → Interview Screen.
/// The actual live interview is handled by InterviewScreen after permissions are granted.
class AIInterviewScreen extends StatelessWidget {
  final int mcqScore;
  final int totalMcq;
  final Map<String, dynamic>? candidateProfile;
  final String? technicalDomain;

  const AIInterviewScreen({
    super.key,
    this.mcqScore = 0,
    this.totalMcq = 0,
    this.candidateProfile,
    this.technicalDomain,
  });

  @override
  Widget build(BuildContext context) {
    final String name = candidateProfile?['name'] as String? ?? 'Candidate';
    final String domain = technicalDomain ?? 'Software Engineer';
    final double mcqPercent = totalMcq > 0 ? (mcqScore / totalMcq) * 100 : 80;

    return PermissionGateScreen(
      candidateName: name,
      company: candidateProfile?['targetCompany'] as String? ?? 'Tech Company',
      role: domain,
      destination: InterviewScreen(
        topic: domain,
        userName: name,
        company: candidateProfile?['targetCompany'] as String? ?? 'Tech Company',
        role: domain,
        difficulty: candidateProfile?['difficulty'] as String? ?? 'Intermediate',
        candidateProfile: candidateProfile,
        aptitudeScore: candidateProfile?['aptitudeScore'] as int? ?? mcqScore,
        numAptitude: candidateProfile?['numAptitude'] as int? ?? (totalMcq ~/ 2),
        technicalScore:
            candidateProfile?['technicalScore'] as int? ?? mcqScore,
        numTechnical: candidateProfile?['numTechnical'] as int? ?? (totalMcq ~/ 2),
        overallPercentage: mcqPercent,
      ),
    );
  }
}
